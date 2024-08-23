# # Helper function to create synthetic 3D images
# function synthetic_image(n_dim::Int, shift::Int)
#     shape = fill(7, n_dim)
#     x = zeros(Float32, shape...)
#     if n_dim == 3
#         x[3-shift:4-shift, 3:4, 3:4] .= 1
#     else
#         x[3-shift:4-shift, 3:4] .= 1
#     end
#     return x
# end

# @testset "AffineRegistration Wrapper Tests" begin
#     # @testset "Basic Registration" begin
#     #     n_dim = 3
#     #     moving = synthetic_image(n_dim, 1)
#     #     static = synthetic_image(n_dim, 0)
        
#     #     moved = register(moving, static, 
#     #         scales = (1,), 
#     #         iterations = (1000,), 
#     #         learning_rate = 1e-1, 
#     #         verbose = false)
        
#     #     # Check if the moved image is close to the static image
#     #     @test isapprox(moved, static, atol=1e-2)
#     # end

#     # @testset "Parameter Initialization" begin
#     #     n_dim = 3
#     #     moving = synthetic_image(n_dim, 1)
#     #     static = synthetic_image(n_dim, 0)
        
#     #     # Test with custom initial parameters
#     #     init_translation = zeros(Float32, n_dim)
#     #     init_rotation = zeros(Float32, n_dim)
#     #     init_zoom = ones(Float32, n_dim)
#     #     init_shear = zeros(Float32, n_dim)
        
#     #     moved = register(moving, static, 
#     #         init_translation = init_translation,
#     #         init_rotation = init_rotation,
#     #         init_zoom = init_zoom,
#     #         init_shear = init_shear,
#     #         scales = (1,), 
#     #         iterations = (100,), 
#     #         verbose = false)
        
#     #     # The result should be different from the input
#     #     @test isapprox(moved, moving) == false
#     # end

#     # @testset "Disable Transformations" begin
#     #     n_dim = 3
#     #     moving = synthetic_image(n_dim, 1)
#     #     static = synthetic_image(n_dim, 0)
        
#     #     # Test with only translation enabled
#     #     moved_translation_only = register(moving, static, 
#     #         with_rotation = false,
#     #         with_zoom = false,
#     #         with_shear = false,
#     #         scales = (1,), 
#     #         iterations = (500,), 
#     #         verbose = false)
        
#     #     # The result should be different from the input but may not perfectly match the static image
#     #     @test isapprox(moved_translation_only, moving) == false
#     #     @test isapprox(moved_translation_only, static, atol=1e-2) == false
#     # end

#     @testset "Custom Dissimilarity Function" begin
#         n_dim = 3
#         moving = synthetic_image(n_dim, 1)
#         static = synthetic_image(n_dim, 0)
        
#         # Define a custom dissimilarity function (MSE in this case)
#         mse_loss = torch.nn.MSELoss()
        
#         moved = register(moving, static, 
#             dissimilarity_function = mse_loss,
#             scales = (1,), 
#             iterations = (500,), 
#             verbose = false)
        
#         # Check if the moved image is close to the static image
#         @test isapprox(moved, static, atol=1e-2)
#     end

#     @testset "Custom Optimizer" begin
#         n_dim = 3
#         moving = synthetic_image(n_dim, 1)
#         static = synthetic_image(n_dim, 0)
        
#         # Use Adam optimizer
#         adam_optimizer = torch.optim.Adam
        
#         moved = register(moving, static, 
#             optimizer = adam_optimizer,
#             scales = (1,), 
#             iterations = (500,), 
#             verbose = false)
        
#         # Check if the moved image is close to the static image
#         @test isapprox(moved, static, atol=1e-2)
#     end
# end