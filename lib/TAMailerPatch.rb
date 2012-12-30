require_dependency 'mailer'

module TAMailerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method :render_multipart_without_ta, :render_multipart unless method_defined?(:render_multipart_without_ta)
      alias_method :render_multipart, :render_multipart_with_ta

      instance_variable_get("@inheritable_attributes")[:view_paths].unshift(File.expand_path(File.join(File.dirname(__FILE__), '../app/views')))
    end
  end

  module InstanceMethods
    def render_multipart_with_ta(method_name, body)
      if method_name == 'issue_edit'
        journal = body[:journal]
        details = journal.details

      end

      render_multipart_without_ta(method_name, body)
    end

  end
end
