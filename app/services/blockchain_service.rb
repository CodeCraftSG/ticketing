class BlockchainService
  def self.receive(return_url)
    begin
      resp = Blockchain::receive(ENV["BITCOIN_WALLET"], return_url)
      resp.input_address
    rescue => e
      Rails.logger.error "Exception: Unable to generate receiving address: #{e.message}"
      raise e
    end
  end
end
