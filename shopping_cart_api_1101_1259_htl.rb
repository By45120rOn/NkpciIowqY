# 代码生成时间: 2025-11-01 12:59:33
# Define a simple Entity for the Product
class ProductEntity < Grape::Entity
  expose :id
  expose :name
  expose :price
end

# Define the Product model, if not already defined
class Product
  attr_accessor :id, :name, :price
end

# Define the Cart Item model
class CartItem
  attr_accessor :product_id, :quantity
end

# Define the ShoppingCart API
class ShoppingCartAPI < Grape::API
  format :json

  # Endpoint to add a product to the cart
  params do
    requires :product_id, type: Integer, desc: 'The ID of the product to add to the cart'
    requires :quantity, type: Integer, desc: 'The quantity of the product to add'
  end
  post 'add_product' do
    product = Product.find(params[:product_id])
    if product
      # Assuming a cart is stored in the session
      if @cart = session[:cart]
        @cart << CartItem.new(product_id: params[:product_id], quantity: params[:quantity])
      else
        session[:cart] = [@cart_item = CartItem.new(product_id: params[:product_id], quantity: params[:quantity])]
      end
      status 201
      ProductEntity.represent(@cart_item, with: ProductEntity)
    else
      error!('Product not found', 404)
    end
  end

  # Endpoint to show the cart contents
  get 'show_cart' do
    if @cart = session[:cart]
      @cart.map { |item| ProductEntity.represent(Product.find(item.product_id), with: ProductEntity) }
    else
      status 204
      nil
    end
  end

  # Endpoint to remove a product from the cart
  params do
    requires :product_id, type: Integer, desc: 'The ID of the product to remove from the cart'
  end
  delete 'remove_product' do
    product_id = params[:product_id]
    if @cart = session[:cart]
      @cart.reject! { |item| item.product_id == product_id }
      status 200
    else
      error!('Cart is empty', 404)
    end
  end

  error_format :json, each: [:message, :status]

  rescue_from :all do |e|
    if e.is_a?(Grape::Exceptions::Validation) || e.is_a?(Grape::Exceptions::MethodOverride) || e.is_a?(Grape::Exceptions::MethodNotAllowed) || e.is_a?(Grape::Exceptions::InvalidAuth)
      error!({ message: e.message, status: e.status }, e.status)
    else
      error!({ message: 'Internal Server Error', status: 500 }, 500)
    end
  end
end
