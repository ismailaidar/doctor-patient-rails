module RetireLeave
	extend ActiveSupport::Concern

	def get_status_msg(action = nil)
    status = { index: :active, msg: "something's wrong", error: false }
    if action == 'retire'
      status[:index] = :retire
      status[:msg] = "the doctor was successfully retire"
    elsif action == 'leave'
      status[:index] = :leave
      status[:msg] = "the doctor was successfully left"
    else
      status[:error] = true
    end
    return status
  end
end