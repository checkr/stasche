RSpec.describe Stasche::Client do
  context 'when passed a configuration block' do
    let(:client) do
      described_class.new do |config|
        config.namespace = 'test'
      end
    end

    it 'configures client' do
      expect(client.namespace).to eql('test')
    end
  end

  context 'when using a custom namespace' do
    let(:client) { described_class.new(namespace: 'test') }

    it 'sets namespace' do
      expect(client.namespace).to eql('test')
    end
  end

  describe '#inspect' do
    let(:encryption_key) { 'super_secret' }
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: encryption_key)
    end

    it 'returns a string which does not contain the encryption key' do
      expect(client.inspect).not_to include(encryption_key)
    end
  end

  describe '#get' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client.set(foo: 'bar') }

    context 'when `expire` set to true' do
      it 'retrieves values from store' do
        expect(client.get('foo')).to eql('bar')
      end

      it 'deletes key' do
        client.get('foo', expire: true)

        expect(client.get('foo')).to be_nil
      end
    end

    context 'when `expire` unset' do
      it 'retrieves values from store' do
        expect(client.get('foo')).to eql('bar')
      end

      it 'does not delete key' do
        client.get('foo')

        expect(client.get('foo')).to eql('bar')
      end
    end
  end

  describe '#set' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    context 'when key already exists' do
      before { client.set(foo: 'bar') }

      it 'throws the proper exception' do
        error_class = Stasche::Store::KeyAlreadyExistsError
        expect { client.set(foo: 'bar') }.to raise_error(error_class)
      end

      it 'does not throws an exception if forced' do
        expect { client.set({ foo: 'bar' }, force: true) }.to_not raise_error
      end
    end
  end

  describe '#ls' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    context 'when not passed a match pattern' do
      before { client.set(foo: 'bar', baz: 'qux') }

      it 'returns all keys' do
        expect(client.ls.sort).to eq(%w[baz foo])
      end
    end

    context 'when passed a match pattern' do
      before { client.set(foo: 'bar', baz: 'qux', bar: 'drink') }

      it 'returns only matching keys' do
        expect(client.ls('ba*').sort).to eq(%w[bar baz])
      end
    end
  end

  describe '#count' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client.set(foo: 'bar', baz: 'qux', bar: 'drink') }

    it 'returns count' do
      expect(client.count).to eq(3)
    end
  end

  describe '#push' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client.push('foo') }

    it 'stores value' do
      expect(client.pop).to eql('foo')
    end
  end

  describe '#<<' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client << 'foo' }

    it 'stores value' do
      expect(client.pop).to eql('foo')
    end
  end

  describe '#peek' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client << 'foo' }

    it 'returns last value' do
      expect(client.peek).to eql('foo')
    end

    it 'does not remove value' do
      client.peek

      expect(client.peek).to eql('foo')
    end
  end

  describe '#last' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client << 'foo' }

    it 'returns last value' do
      expect(client.last).to eql('foo')
    end

    it 'does not remove value' do
      client.last

      expect(client.last).to eq('foo')
    end
  end

  describe '#pop' do
    let(:client) do
      described_class.new(encrypter: Encrypter, encryption_key: 'foo')
    end

    before { client << 'foo' }

    it 'returns last value' do
      expect(client.pop).to eql('foo')
    end

    it 'removes value' do
      client.pop

      expect(client.ls).to be_empty
    end
  end
end
