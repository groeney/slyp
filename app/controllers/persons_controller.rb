class PersonsController < BaseController
  before_action :authenticate_user!

  def index
    @persons = User.all
    render status: 200, json: present_collection(@persons),
           each_serializer: PersonSerializer
  end

  def show
    @person = User.find(params[:id])
    render status: 200, json: present(@person),
           serializer: PersonSerializer
  end

  def invite
    @invitee = User.invite!(invite_params, current_user)
    return render_422(@invitee) unless @invitee.valid?
    current_user.befriend(@invitee.id)
    render status: 201, json: present(@invitee),
           serializer: PersonSerializer
  end

  private

  def present(person)
    PersonPresenter.new person, current_user.friendship(person.id)
  end

  def present_collection(persons)
    persons.map { |person| present(person) }
  end

  def invite_params
    { email: params[:email] }
  end
end
