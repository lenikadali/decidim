# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to promote a managed user.
    #
    # Managed users can be promoted to standard users. It means they
    # will be invited to the application and will lose the managed flag
    # so the user cannot be impersonated anymore.
    class PromoteManagedUser < Decidim::Command
      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # user         - The user to promote
      def initialize(form, user)
        @form = form
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid? || !user.managed? || email_already_exists?

        promote_user
        invite_user
        create_action_log

        broadcast(:ok)
      end

      attr_reader :form, :user

      private

      def promote_user
        user.email = form.email.downcase
        user.skip_reconfirmation!
        user.save(validate: false)
      end

      def invite_user
        user.invite!(current_user)
      end

      def email_already_exists?
        Decidim::User.where(email: form.email.downcase).any?
      end

      def create_action_log
        Decidim.traceability.perform_action!(
          "promote",
          user,
          form.current_user,
          visibility: "admin-only"
        )
      end
    end
  end
end
