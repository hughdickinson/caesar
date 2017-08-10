class WorkflowsController < ApplicationController
  def index
    @workflows = Workflow.accessible_by(credential).all
    respond_with @workflows
  end

  def show
    respond_with workflow
  end

  def new
    unless params[:id].present?
      head :bad_request
      return
    end

    if workflow = Workflow.accessible_by(credential).find_by(id: params[:id])
      redirect_to workflow
      return
    end

    workflow_hash = credential.accessible_workflow?(params[:id])

    if workflow_hash.present?
      @workflow = Workflow.new(id: params[:id], project_id: workflow_hash["links"]["project"])
    else
      head :not_found
    end
  end

  def create
    workflow_hash = credential.accessible_workflow?(params[:workflow][:id])

    unless workflow_hash.present?
      head :forbidden
      return
    end

    @workflow = Workflow.new(id: params[:workflow][:id], project_id: workflow_hash["links"]["project"])

    if @workflow.save
      redirect_to workflow
    end
  end

  def update
    workflow.update!(workflow_params)
    respond_with workflow
  end

  private

  def authorized?
    true
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:id])
  end

  def workflow_params
    params.require(:workflow).permit(
      extractors_config: {},
      reducers_config: {},
      rules_config: {}
    )
  end
end
