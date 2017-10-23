RSpec.describe Stasche do
  let(:configurations) do
    {
      redis: {
        store: :redis,
        url: '127.0.0.1:6379',
        encrypter: Encrypter,
        encryption_key: 'foo'
      },
      s3: {
        store: :s3,
        bucket: 'stasche',
        region: 'us-east-1',
        encrypter: Encrypter,
        encryption_key: 'foo'
      }
    }
  end

  [:redis, :s3].each do |backend|
    context "when configured with #{backend} backend" do
      before do
        described_class.configure do |config|
          configurations[backend].each do |key, val|
            config.send("#{key}=", val)
          end
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
  end
end
