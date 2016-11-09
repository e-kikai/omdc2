class SystemAction
  # before_action時に呼び出される
  def before(controller)

    controller.logger.debug "before: #{controller.action_name}"


  end


end
