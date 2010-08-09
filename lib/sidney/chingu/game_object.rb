module Chinguclass GameObject
  public
  def toggle
    visible? ? hide! : show!

    visible?
  end
endend