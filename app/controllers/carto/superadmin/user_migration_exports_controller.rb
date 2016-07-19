# encoding: UTF-8

require_dependency 'resque/user_migration_jobs'

module Carto
  module Superadmin
    class UserMigrationExportsController < ::Superadmin::SuperadminController
      respond_to :json

      ssl_required [:show, :create]

      def create
        export = Carto::UserMigrationExport.new(
          user_id: params[:user_id],
          organization_id: params[:organization_id]
        )
        if export.save
          Resque.enqueue(Resque::UserMigrationJobs::Export, export_id: export.id)
          render json: UserMigrationExportPresenter.new(export).to_poro, status: 201
        else
          render json: { errors: export.errors.to_h }, status: 422
        end
      end

      def show
        export = Carto::UserMigrationExport.find(params[:id])
        render json: UserMigrationExportPresenter.new(export).to_poro
      end
    end
  end
end
