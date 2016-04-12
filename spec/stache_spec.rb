RSpec.describe Stache do
  context 'when configured' do
    before do
      described_class.configure do |config|
        config.store = :redis
        config.url   = '127.0.0.1:6379'
      end
    end

    describe '.client' do
      it 'returns client' do
        expect(described_class.client).to be_an_instance_of(
          described_class::Client
        )
      end
    end
  end

  context 'when not configured' do
    before { Thread.current[:stache_instance] = nil }

    describe '.client' do
      it 'fails' do
        expect { described_class.client }.to raise_error RuntimeError
      end
    end
  end
end
