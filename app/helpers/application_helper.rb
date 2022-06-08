module ApplicationHelper
  def nl2br(str)
    h(str).gsub(/\R/, "<br />").html_safe
  end
end
