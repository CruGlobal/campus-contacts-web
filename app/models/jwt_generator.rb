JWTGenerator = Struct.new(:user) do
  def generate
    payload = { user_id: user.id, exp: 2.hours.from_now.to_i }
    JWT.encode(payload, ENV['JSON_WEB_TOKEN_SECRET'], 'HS256')
  end
end
