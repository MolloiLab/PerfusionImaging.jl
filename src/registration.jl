# export register

# # function register(
# #     moving::AbstractMatrix, static::AbstractMatrix;
# #     scales=(4, 2),
# #     iterations=(500, 100),
# #     learning_rate=1e-2,
# #     verbose=true,
# #     dissimilarity_function=torch.nn.MSELoss(),
# #     optimizer=torch.optim.Adam,
# #     init_translation=nothing,
# #     init_rotation=nothing,
# #     init_zoom=nothing,
# #     init_shear=nothing,
# #     with_translation=true,
# #     with_rotation=true,
# #     with_zoom=true,
# #     with_shear=false,
# #     align_corners=true,
# #     interp_mode=nothing,
# #     padding_mode="border")

# #     reg = torchreg.AffineRegistration(
# #         is_3d=false,
# #         scales=scales,
# #         iterations=iterations,
# #         learning_rate=learning_rate,
# #         verbose=verbose,
# #         dissimilarity_function=dissimilarity_function,
# #         optimizer=optimizer,
# #         init_translation=init_translation,
# #         init_rotation=init_rotation,
# #         init_zoom=init_zoom,
# #         init_shear=init_shear,
# #         with_translation=with_translation,
# #         with_rotation=with_rotation,
# #         with_zoom=with_zoom,
# #         with_shear=with_shear,
# #         align_corners=align_corners,
# #         interp_mode=interp_mode,
# #         padding_mode=padding_mode
# #     )

# #     moving_batched_channel = reshape(moving, (1, 1, size(moving)...))
# #     static_batched_channel = reshape(static, (1, 1, size(static)...))
# #     moving_batched_channel = torch.from_numpy(np.array(moving_batched_channel))
# #     static_batched_channel = torch.from_numpy(np.array(static_batched_channel))
# #     moved = reg(moving_batched_channel, static_batched_channel)
# #     moved_jl = pyconvert(Array, moved)
# #     moved_jl = dropdims(moved_jl; dims=(1, 2))
# #     return moved_jl
# # end

# function register(
#     moving::AbstractArray{T,3}, static::AbstractArray{T,3};
#     scales=(4, 2),
#     iterations=(500, 100),
#     learning_rate=1e-2,
#     verbose=true,
#     dissimilarity_function=torch.nn.MSELoss(),
#     optimizer=torch.optim.Adam,
#     init_translation=nothing,
#     init_rotation=nothing,
#     init_zoom=nothing,
#     init_shear=nothing,
#     with_translation=true,
#     with_rotation=true,
#     with_zoom=true,
#     with_shear=false,
#     align_corners=true,
#     interp_mode=nothing,
#     padding_mode="border") where {T}

#     reg = torchreg.AffineRegistration(
#         is_3d=true,
#         scales=scales,
#         iterations=iterations,
#         learning_rate=learning_rate,
#         verbose=verbose,
#         dissimilarity_function=dissimilarity_function,
#         optimizer=optimizer,
#         init_translation=init_translation,
#         init_rotation=init_rotation,
#         init_zoom=init_zoom,
#         init_shear=init_shear,
#         with_translation=with_translation,
#         with_rotation=with_rotation,
#         with_zoom=with_zoom,
#         with_shear=with_shear,
#         align_corners=align_corners,
#         interp_mode=interp_mode,
#         padding_mode=padding_mode
#     )

#     moving_batched_channel = reshape(moving, (1, 1, size(moving)...))
#     static_batched_channel = reshape(static, (1, 1, size(static)...))
#     moving_batched_channel = torch.from_numpy(np.array(moving_batched_channel))
#     static_batched_channel = torch.from_numpy(np.array(static_batched_channel))
#     moved = reg(moving_batched_channel, static_batched_channel)
#     moved_jl = pyconvert(Array, moved)
#     moved_jl = dropdims(moved_jl; dims=(1, 2))
#     return moved_jl
# end

