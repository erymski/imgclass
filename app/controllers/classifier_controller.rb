class ClassifierController < UserController
    def dashboard
        @jobs = Job.where(user_id: current_user.id).select{ |job| job.isOpen } # ER: not optimal, but OK for small number of jobs/users
    end
end