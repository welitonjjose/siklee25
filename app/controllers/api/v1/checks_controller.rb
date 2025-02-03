class Api::V1::ChecksController <  ActionController::API
  def verify_opt
    return unless params[:email].length > 0

    resource_class = params[:resource].constantize
    base = resource_class.find_by(email: params[:email])
    if base.nil?
      return render json: {
        msg: "#{params[:resource].capitalize} Não Encontrado",
        isUser: false
      }, status: :ok
    end

    return render json: {
      opt: base.opt?,
      isUser: true
    }
  end

  def send_email_with_code
    code = generate_code
    resource = params[:resource].constantize.find_by(email: params[:email])
    resource.update(code: code, code_at: Time.now + 30.minutes)

    return render json: resource
  end

  def verify_code

    resource = params[:two_fa][:resource].constantize.find_by(email: params[:two_fa][:email])
    if params[:two_fa][:code] == resource.code
      resource.update(valid_opt_at: Time.now + 30.minutes, code: nil, code_at: nil)
      return redirect_to root_path
    end
  end

  private

  def generate_code
    6.times.map { rand(10) }.join("")
  end
end
