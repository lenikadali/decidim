# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to filter resources
  module FilterResource
    extend ActiveSupport::Concern

    # Internal: Defines a class that will wrap in an object the URL params used by the filter.
    # this way we can use Rails' form helpers and have automatically checked checkboxes and
    # radio buttons in the view, for example.
    class Filter
      def initialize(filter)
        @filter = filter
      end

      def method_missing(method_name, *_arguments)
        method = method_name.to_s.gsub(/\[[0-9]+\]$/, "").to_sym
        @filter.present? && @filter.has_key?(method) ? @filter[method] : super
      end

      def respond_to_missing?(method_name, include_private = false)
        method = method_name.to_s.gsub(/\[[0-9]+\]$/, "").to_sym
        (@filter.present? && @filter.has_key?(method)) || super
      end
    end

    included do
      helper_method :search, :filter_params, :filter

      private

      def search
        @search ||= search_with(filter_params)
      end

      def search_with(provided_params)
        search_collection.ransack(provided_params, context_params.merge(auth_object: current_user))
      end

      def search_collection
        raise NotImplementedError, "A search class is needed to filter resources"
      end

      def filter
        @filter ||= Filter.new(filter_params)
      end

      # Fetches the correct filter parameters from the request parameters in
      # order to limit the parameters which can be used for searching the
      # resources. Otherwise the user could pass extra search parameters from
      # the request using the Ransack API.
      def filter_params
        @filter_params = begin
          passed_params = params.to_unsafe_h[:filter].try(:symbolize_keys) || {}
          passed_params.transform_values! do |value|
            next nil if value == all_value
            next value.compact_blank if value.is_a? Array

            value
          end
          default_filter_params.merge(passed_params.slice(*default_filter_params.keys))
        end
      end

      def default_filter_params
        {}
      end

      def all_value
        nil
      end

      # If the controller responds to current_component, its is probably
      # searching against that component. Otherwise it is be likely to search
      # against a participatory space. The context params are passed to the
      # Ransack search classes which may be customized per model in case they
      # need this contextual information. For such searches, take a look at the
      # ResourceSearch class or any search class inheriting from that which
      # utilize this context information, such as the current user.
      def context_params
        context = {
          current_user:,
          organization: current_organization
        }
        context[:component] = current_component if respond_to?(:current_component)

        context
      end
    end
  end
end
