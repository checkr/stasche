RSpec.describe Stasche do
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

      %i[
        get
        set
        ls
        count
        push
        <<
        peek
        last
        pop
        del
      ].each do |method_name|
        it "delegates #{method_name} to `client`" do
          allow(described_class.client).to receive(method_name)

          described_class.method(method_name).call

          expect(described_class.client).to have_received(method_name)
        end
      end
    end
  end

  context 'when not configured' do
    before { Thread.current[:stasche_instance] = nil }

    describe '.client' do
      it 'fails' do
        expect { described_class.client }.to raise_error RuntimeError
      end
    end
  end
end
