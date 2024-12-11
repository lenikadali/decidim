# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class ParticipatorySpaceProposals < Decidim::Query
        # Sugar syntax. Retrieve all proposals for the given sortition.
        def self.for(sortition)
          new(sortition).query
        end

        # Initializes the class.
        #
        # sortition - a sortition to select proposals
        def initialize(sortition)
          @sortition = sortition
          @taxonomies = sortition.taxonomies
          @request_timestamp = sortition.request_timestamp
        end

        # Given a participatory process retrieves its proposals
        #
        # Returns an ActiveRecord::Relation.
        def query
          proposals = Decidim::Proposals::Proposal
                      .not_withdrawn
                      .published
                      .not_hidden
                      .where(decidim_proposals_proposals: { created_at: ...request_timestamp })
                      .where(component: sortition.decidim_proposals_component)
          proposals = proposals.where.not(id: proposals.only_status(:rejected))

          return proposals.order(id: :asc) if taxonomies.blank?

          # taxonomization -> taxonomy
          proposals.with_taxonomies(*taxonomies.map(&:id)).order(id: :asc)
        end

        private

        attr_reader :sortition, :taxonomies, :request_timestamp
      end
    end
  end
end
