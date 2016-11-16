class ClassifierController < UserController
    def dashboard
        @jobs = Job.where(user_id: current_user.id)
    end
end