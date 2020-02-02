class PeriodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_period, only: [:edit, :update, :destroy]
  authorize_resource

  def index
    @periods = Period.all.order(start_time: :asc, end_time: :asc).page(params[:page]).per(20)
  end

  def new
    @period = Period.new(start_time: '07:00', end_time: '07:50')
  end

  def edit
  end

  def create
    @period = Period.new(period_params)

    respond_to do |format|
      if @period.save
        format.html { redirect_to periods_url, notice: "#{Period.model_name.human}を作成しました。" }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to periods_url, notice: "#{Period.model_name.human}を更新しました。" }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @period.destroy
    respond_to do |format|
      format.html { redirect_to periods_url, notice: "#{Period.model_name.human}を削除しました。" }
    end
  end

  private
    def set_period
      @period = Period.find(params[:id])
    end

    def period_params
      period_ps = params.require(:period).permit(:start_time, :end_time)
      # Hashの時刻パラメータを文字列変換
      [:start_time, :end_time].each do |key|
        key4i = "#{key}(4i)"
        key5i = "#{key}(5i)"
        if period_ps.key?(key4i) && period_ps.key?(key5i)
          period_ps[key] = "#{period_ps[key4i]}:#{period_ps[key5i]}"
          period_ps.delete(key4i)
          period_ps.delete(key5i)
        end
      end
      period_ps
    end
end
