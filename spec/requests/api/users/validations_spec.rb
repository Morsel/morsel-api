require_relative '_spec_helper'

describe 'GET /users/validate_email users#validate_email' do
  let(:endpoint) { '/users/validate_email' }
  let(:user) { FactoryGirl.create(:user) }

  it 'returns true if the email does NOT exist' do
    get_endpoint email: 'marty@rock.lobster'

    expect_success
    expect(json_data).to eq(true)
  end

  it 'returns an error if the email is nil' do
    get_endpoint

    expect_failure
    expect(json_errors['email']).to include('is required')
  end

  it 'returns an error if the email is invalid' do
    get_endpoint email: 'a_bad_email_address'

    expect_failure
    expect(json_errors['email']).to include('is invalid')
  end

  it 'returns an error if the email already exists' do
    get_endpoint email: user.email

    expect_failure
    expect(json_errors['email']).to include('has already been taken')
  end

  it 'ignores case' do
    get_endpoint email: user.email.swapcase

    expect_failure
    expect(json_errors['email']).to include('has already been taken')
  end
end

describe 'GET /users/validate_username users#validate_username' do
  let(:endpoint) { '/users/validate_username' }
  let(:user) { FactoryGirl.create(:user) }

  it 'returns true if the username does NOT exist' do
    get_endpoint username: 'not_a_username'

    expect_success
    expect(json_data).to eq(true)
  end

  it 'returns an error if the username is nil' do
    get_endpoint

    expect_failure
    expect(json_errors['username']).to include('is required')
  end

  it 'returns an error if the username is too long' do
    get_endpoint username: 'longlonglonglong'

    expect_failure
    expect(json_errors['username']).to include('must be less than 16 characters')
  end

  it 'returns an error for spaces' do
    get_endpoint username: 'Bob Dole'

    expect_failure
    expect(json_errors['username']).to include('cannot contain spaces')
  end

  it 'returns an error if the username already exists' do
    get_endpoint username: user.username

    expect_failure
    expect(json_errors['username']).to include('has already been taken')
  end

  it 'ignores case' do
    get_endpoint username: user.username.swapcase

    expect_failure
    expect(json_errors['username']).to include('has already been taken')
  end

  context 'username is a reserved path' do
    let(:sample_reserved_path) { ReservedPaths.non_username_paths.sample }
    it 'returns true to say the username already exists' do
      get_endpoint username: sample_reserved_path

      expect_failure
      expect(json_errors['username']).to include('has already been taken')
    end
  end
end
