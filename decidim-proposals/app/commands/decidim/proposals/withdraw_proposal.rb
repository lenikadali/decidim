# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user withdraws a new proposal.
    class WithdrawProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to withdraw.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :has_votes if the proposal already has votes or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:has_votes) if @proposal.votes.any?

        transaction do
          @proposal.withdraw!
          reject_emendations_if_any
        end

        broadcast(:ok, @proposal)
      end

      private

      def reject_emendations_if_any
        return if @proposal.emendations.empty?

        @proposal.emendations.each do |emendation|
          @form = form(Decidim::Amendable::RejectForm).from_params(id: emendation.amendment.id)
          result = Decidim::Amendable::Reject.call(@form)
          return result[:ok] if result[:ok]
        end
      end
    end
  end
end
