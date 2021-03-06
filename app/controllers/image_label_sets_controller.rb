class ImageLabelSetsController < UserController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy]
  require 'fileutils'
  require 'pathname'
  require 'kaminari'
  require 'fastimage'
  require 'zip'
  require 'pry'

  require 'image_file_utils'
  include ImageFileUtils
  
  # GET /image_label_sets
  # GET /image_label_sets.json
  def index
    @image_label_sets = ImageLabelSet.all
  end

  # GET /image_label_sets/1
  # GET /image_label_sets/1.json
  def show
    @imageDir = @image_label_set.image_set.vdir
    if params.has_key?(:page)
      @images = Kaminari.paginate_array(@image_label_set.image_set.images).page(params[:page])
    else
      @images = Kaminari.paginate_array(@image_label_set.image_set.images).page(1) # .per(1)
    end
  end

  # GET /image_label_sets/new
  def new
    @image_label_set = ImageLabelSet.new
    @image_label_set.image_set = ImageSet.new
    @image_label_set.label_set = LabelSet.new
    @image_label_set.user = current_user # controller assumes logged-in user, so it's safe

  end

  # GET /image_label_sets/1/edit
  def edit
  end

  # POST /image_label_sets
  # POST /image_label_sets.json
  def create
    @image_label_set = ImageLabelSet.new
    @image_label_set.user = current_user # controller assumes logged-in user, so it's safe

    label_set = LabelSet.new
    label_set.save
    @image_label_set.label_set_id = label_set.id

    # whitespace and comma are separators
    params["labels"].split(/[\s,]/).reject { |l| l.empty? }.each do |l|
      lb = Label.new
      lb.text = l
      lb.label_set_id = @image_label_set.label_set_id
      lb.save
    end

    image_set = ImageSet.new
    image_set.name = params["name"] || "Unnamed"
    image_set.save

    imageDir = image_set.local_dir
    FileUtils::mkdir_p imageDir
    @image_label_set.image_set_id = image_set.id

    Image.transaction do

      params["upload"].each do |uf|
        #Check if zipfile or raw images
        if (File.extname(uf.tempfile.path)==".zip")
          Zip::File.open(uf.tempfile.path) do |zipfile|
          zipfile.each do |file|
            if(file.ftype == :file)
              new_path = imageDir + File.basename(file.name)
              puts new_path
              zipfile.extract(file, new_path) unless File.exist?(new_path)
              fs = FastImage.size(new_path)
              if (fs and fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
                i = Image.new
                i.filename = File.basename(file.name)
                i.image_set_id = @image_label_set.image_set_id
                i.save
              else
                logger.warn "Skip " + new_path
                FileUtils.rm(new_path)
              end
            end
            end
          end
        else
          fs = FastImage.size(uf.tempfile.path)
          if (fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
            i = Image.new
            new_path = imageDir + uf.original_filename.to_s
            FileUtils.mv(uf.tempfile.path, new_path)
            i.filename = uf.original_filename.to_s
            i.image_set_id = @image_label_set.image_set_id
            i.save
          end
        end
        uf.tempfile.close
        uf.tempfile.unlink
      end

    end

    respond_to do |format|
      if (@image_label_set.save)
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully created.' }
        format.json { render :show, status: :created, location: @image_label_set }
      else
        format.html { render :new }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # pre-allocate images for labeling
  def alloc

    #Create a new ImageLabel for each image in this set
    ImageLabelSet.transaction do
      ils = ImageLabelSet.find(params[:id]).image_set.images.each do |image|
        il = ImageLabel.new()
        il.image = image
        il.save
      end
    end

    redirect_to action: "index", notice: "Images successfully allocated"
  end

  def download
    ils = ImageLabelSet.find(params[:id])
#    set_name = ils.image_set.name
    labelsPath = ils.generateLabelsTextfile
    image_set_id = ils.image_set.id 

    folder = dir_for_set(image_set_id)
    input_filenames = Dir.entries(folder) - %w(. ..)
    zipfile_name = "/tmp/trainingset.zip"
    FileUtils.rm_rf(zipfile_name)

    # TODO: will fail if several users generating downloads. low prio
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, folder + '/' + filename)
      end
      zipfile.add("labels.txt", labelsPath)
    end

    send_file zipfile_name, :filename => "trainingset.zip", disposition: 'attachment'
  end

  def assign
    @image_label_set = ImageLabelSet.find(params[:id])
    @workers = User.where(:is_admin => false)
    @openjobs = Job.all.select{|j| j.isOpen}
    @completedjobs = Job.all.select{|j| j.isComplete}
    @job = Job.new
  end

  def createjob
    #Create a new Job
    j = Job.new

    ils_id = params[:id]

    #Assign this job to worker
    j.user_id = params[:userid]
    j.image_label_set_id = ils_id # store related ILS
    j.save

    #Get the next N image_labels for this image_label_set
    ims = ImageLabelSet.find(ils_id)
    batch = ims.batchOfRemainingLabels(5000)
    #Assign the next N image_labels to this job

    ImageLabelSet.transaction do
      batch.each do |il|
        il.job_id = j.id
        il.save
      end
    end

    #binding.pry

    redirect_to action: "assign", id: ils_id
  end

  # PATCH/PUT /image_label_sets/1
  # PATCH/PUT /image_label_sets/1.json
  def update
    respond_to do |format|
      if @image_label_set.update(image_label_set_params)
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully updated.' }
        format.json { render :show, status: :ok, location: @image_label_set }
      else
        format.html { render :edit }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_label_sets/1
  # DELETE /image_label_sets/1.json
  def destroy
    @image_label_set.destroy
    respond_to do |format|
      format.html { redirect_to image_label_sets_url, notice: 'Image label set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_label_set
      @image_label_set = ImageLabelSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_label_set_params
      params.permit!
      #params.require(:image_label_set).permit(:image_set_id, :label_set_id, :user_id)
    end
end
