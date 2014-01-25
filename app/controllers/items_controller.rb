class ItemsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :load_item, :only => [:edit, :update, :show, :purchase, :pause, :activate]

  def purchase
    if @item.purchase!(current_user)
      flash[:notice] = "Payment was successful"
      Mailer.item_purchased(@item, current_user).deliver
      redirect_to @item
    else
      @comments = @item.comments.order(:created_at)
      @comment  = @item.comments.new
      flash[:alert] = "Insufficient Funds"
      render 'show'
    end
  end

  def show
    @comments = @item.comments.order(:created_at)
    @comment  = @item.comments.new
  end

  def new
    @item = current_user.items.new
    @categories = Category.all
  end

  def create
    @item = current_user.items.new(params[:item])
    if @item.save
      flash[:notice] = "Created item successfuly"
      redirect_to @item
    else
      render 'new'
    end
  end

  def pause
    @item.pause!
    flash[:notice] = "Item is paused"
    redirect_to @item
  end

  def activate
    @item.activate!
    flash[:notice] = "Item is active!"
    redirect_to @item
  end

  def update
    if @item.update_attributes(params[:item]) 
      redirect_to items_path, :notice => "Updated item successfuly"
    else
      render 'edit'
    end
  end

  def index
    @items = Item.of_approved_users.active
  end

  private
  
    def load_item
      @item = Item.find(params[:id])
    end

end