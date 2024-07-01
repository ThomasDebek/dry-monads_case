class ProductsController < ApplicationController
  include Dry::Monads[:result]

  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
    result = find_product(params[:id])

    case result
    when Success
      @product = result.value!
    when Failure
      redirect_to products_path, alert: result.failure
    end
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    result = find_product(params[:id])
    case result
    when Success
      @product = result.value!
    when Failure
      redirect_to product_path, alert: result.failure
    end
  end

  # POST /products or /products.json
  def create
    result = create_product(product_params)

    case result
    when Success
      redirect_to product_path(result.value!), notice: 'Product was successfully created.'
    when Failure
      @product = Product.new(product_params)
      flash[:alert] = result.failure
      render :new
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    result = update_product(params[:id], product_params)

    case result
    when Success
      redirect_to product_path(result.value!), notice: 'Product was successfully updated.'
    when Failure
      @product = find_product(params[:id]).value!
      flash[:alert] = result.failure
      render :edit
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    result = destroy_product(params[:id])
    case result
    when Success
      redirect_to products_path, notice: 'Product was successfully destroyed.'
    when Failure
      redirect_to proucts_path, alert: 'Product was successfully destroyed.'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  def find_product(id)
    product = Product.find_by(id: id)
    if product
      Success(product)
    else
      Failure("product not found")
    end
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:name, :price)
  end

  def create_product(params)
    product = Product.new(params)
    if product.save
      Success(product)
    else
      Failure("Product not Found :|")
    end
  end

  def update_product(id, params)
    result = find_product(id)
    return result if result.failure?

    product = result.value!
    if product.update(params)
      Success(product)
    else
      Failure(product.errors.full_messages.to_sentence)
    end
  end

  def destroy_product(id)
    result = find_product(id)
    return result if result.failure?

    product = result.value!
    if product.destroy
      Success(product)
    else
      Failure("Failed to destroy the product")
    end
  end


end
