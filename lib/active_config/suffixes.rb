class ActiveConfig

  class HashWithHooks < HashConfig
    attr_accessor :write_hooks
    alias_method :regular_writer_hwh, :regular_writer unless method_defined?(:regular_writer_hwh)

    def write_hooks
      @write_hooks ||= []
    end

    def regular_writer(*args)
      write_hooks.each{|p|p.call}
      regular_writer_hwh(*args)
    end

    def add_write_hook func=nil,&block
      self.write_hooks||=[]
      self.write_hooks << func if Proc===func
      self.write_hooks << block if Kernel.block_given?
    end

  end

  class Suffixes
    attr_writer :priority
    attr_accessor :ac_instance
    attr :symbols

    def overlay= new_overlay
      ac_instance._flush_cache
      @symbols[:overlay]=(new_overlay.respond_to?(:upcase) ? new_overlay.upcase : new_overlay)
    end

    def initialize(*args)
      ac_instance=args.shift
      @symbols=HashWithHooks.new
      @symbols[:hostname]=proc {|sym_table| ENV['ACTIVE_CONFIG_HOSTNAME'] ||
       Socket.gethostname
      }
      @symbols[:hostname_short]=proc {|sym_table| sym_table[:hostname].call(sym_table).sub(/\..*$/, '').freeze}
      @symbols[:rails_env] = proc { |sym_table|
        if defined?(RAILS_ENV)
          RAILS_ENV
        elsif defined?(Rails) and Rails.respond_to?(:env)
          Rails.env
        elsif ENV['ACTIVE_CONFIG_FORCE_RAILS_ENV']
          ENV['ACTIVE_CONFIG_FORCE_RAILS_ENV']
        else
          ENV['RAILS_ENV']
        end
      }
      @symbols[:overlay]=proc { |sym_table| ENV['ACTIVE_CONFIG_OVERLAY']}
      @symbols.add_write_hook do
        ac_instance.flush_cache
      end
      @priority=[
       nil,
       :rails_env,
       [:rails_env,:local],
       :overlay,
       [:overlay,:local],
       [:hostname_short],
       [:hostname_short, :local],
       :hostname,
       [:hostname, :local],
       :local,
      ]
    end

    def method_missing method, val=nil
      super if method.to_s=~/^_/

      if method.to_s=~/^(.*)=$/
        ac_instance._flush_cache
        return @symbols[$1]=val
      end

      ret=@symbols[method]

      if ret
        return ret.call(@symbols) if ret.respond_to?(:call)
        return ret
      end

      super
    end

    def for file, ext=''
      suffixes.map { |this_suffix| [file,*this_suffix].compact.join('_') + ext}.compact.uniq
    end

    def suffixes ary=@priority
      ary.map{|e|
        if Array===e
          t=self.suffixes(e).compact
          t.size > 0 ? t.join('_') : nil
        elsif @symbols[e]
          method_missing(e)
        else
          e && e.to_s
        end
      }
    end

    def file fname
      suffixes.map{|m|m="#{m}" if m
"#{fname}#{m}.yml"
}
    end
  end
end
