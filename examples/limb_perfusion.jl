### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ eeba971b-c64e-4195-95ca-5cf2ae5ac590
# ╠═╡ show_logs = false
begin
    using Pkg; Pkg.activate(; temp = true)

	Pkg.add("CondaPkg")
    Pkg.add("DICOM")
    Pkg.add("CairoMakie")
    Pkg.add("PlutoUI")
    Pkg.add("ImageMorphology")
    Pkg.add("Statistics")
    Pkg.add("DataFrames")
	Pkg.develop(path = "/Users/daleblack/Library/CloudStorage/GoogleDrive-djblack@uci.edu/My Drive/dev/julia/PerfusionImaging")

    using DICOM, CairoMakie, PlutoUI, ImageMorphology, Statistics, DataFrames
	using PerfusionImaging
end

# ╔═╡ 0129d839-fde4-46bf-a2e1-beb79fdd2cab
TableOfContents()

# ╔═╡ b4252854-a892-48d1-9c67-4b4ac3b74ded
md"""
# Load DICOMs
"""

# ╔═╡ 6fa28ef7-8e95-43af-9ef1-9fb549590bf7
md"""
## Choose Main Path
"""

# ╔═╡ aa13d033-c4a1-455c-8fa2-5cfc5a51b9c2
md"""
**Enter Root Directory**

Provide the path to the main folder containing the raw DICOM files and segmentations. Then click submit.

$(@bind root_path confirm(PlutoUI.TextField(60; default = "/Users/daleblack/Library/CloudStorage/GoogleDrive-djblack@uci.edu/My Drive/Datasets/perfusion/limb")))
"""

# ╔═╡ a830eebb-faf8-492b-ac42-2109e5173482
md"""
## V1 & V2
"""

# ╔═╡ 87284291-da14-4a86-8af1-2dcd8d845eee
function volume_paths(dcm, v1, v2)
	
	return PlutoUI.combine() do Child
		
		inputs = [
			md""" $(dcm): $(
				Child(PlutoUI.TextField(60; default = "DICOM"))
			)""",
			md""" $(v1): $(
				Child(PlutoUI.TextField(60; default = "01"))
			)""",
			md""" $(v2): $(
				Child(PlutoUI.TextField(60; default = "02"))
			)"""
		]
		
		md"""
		**Upload Volume Scans**

		Provide the folder names for the necessary files. First input the name of the folder containing the DICOM scans (default is `DICOM`) and then enter the names of the v1 and v2 scans (default is `01` and `02`, respectively). Then click submit.
		
		$(inputs)
		"""
	end
end

# ╔═╡ 42ff7c1a-42ce-4b1c-b1c0-3d8882bd8340
@bind volume_files confirm(volume_paths("Enter DICOM folder name", "Enter volume scan 1 folder name", "Enter volume scan 2 folder name"))

# ╔═╡ c84f0933-8354-4f89-ab16-032cdebb1101
volume_files

# ╔═╡ 26b7a474-0653-4ff4-9455-df1448623fee
dicom_path = joinpath(root_path, volume_files[1])

# ╔═╡ 185d08b1-a1f7-4bf2-b0c3-84af66dcc415
path_v1 = joinpath(dicom_path, volume_files[2])

# ╔═╡ 5e985484-17d3-47b9-b764-c0c714cc0df1
path_v2 = joinpath(dicom_path, volume_files[3])

# ╔═╡ baeb5520-a946-4ce5-9d66-c0407d47cca2
dcms_v1 = dcmdir_parse(path_v1)

# ╔═╡ 5e1c9271-f4cf-4bbf-bf66-e8f12debf08a
dcms_v2 = dcmdir_parse(path_v2)

# ╔═╡ 82a0af24-d4a9-461b-b054-90fe37fa61e5
md"""
## SureStart
"""

# ╔═╡ 43c9c836-2492-431a-9664-d4f900279b2e
md"""
**Enter SureStart Folder**

Input the name of the folder containing the SureStart scans (default is `SureStart`). Then click submit

$(@bind surestart_folder confirm(PlutoUI.TextField(60; default = "SureStart")))
"""

# ╔═╡ 7f54d3c0-945e-4bc3-b2de-f37d93208963
surestart_path = joinpath(root_path, surestart_folder);

# ╔═╡ 0c7580e8-3e49-44bf-b53e-5070be62e722
dcms_ss = dcmdir_parse(surestart_path);

# ╔═╡ 795e6621-0df8-49e5-973a-ada9b37e451f
md"""
## Segmentations
"""

# ╔═╡ 9e791737-a82f-4b07-b6da-fe8d4af1bfe1
md"""
**Enter Segmentation Root Folder**

Input the name of the folder containing the segmentation(s) (default is `SEGMENT_dcm`). Then click submit

$(@bind segment_folder confirm(PlutoUI.TextField(60; default = "SEGMENT_dcm")))
"""

# ╔═╡ 10b527a0-18d9-4d59-8556-fee3b2c90fe2
segmentation_root = joinpath(root_path, "SEGMENT_dcm")

# ╔═╡ 9d76a68a-d983-41bb-90c8-02853fa5f37f
md"""
### Limb
"""

# ╔═╡ bec6e715-47f9-42b4-9ce7-6df632b8ff54
md"""
**Enter Limb Segmentation Folder**

Input the name of the folder containing the SureStart scans (default is `Limb_dcm`). Then click submit

$(@bind limb_folder confirm(PlutoUI.TextField(60; default = "Limb_dcm")))
"""

# ╔═╡ be43dea5-69a4-449c-9423-864c53e728c0
limb_path = joinpath(segmentation_root, limb_folder)

# ╔═╡ 320330e3-7309-48aa-ac4b-123e9c23795a
dcms_limb = dcmdir_parse(limb_path)

# ╔═╡ b458422d-0949-4581-9c68-9872ba67e26e
md"""
### Femoral Artery
"""

# ╔═╡ ca6f06be-b7e9-4cc8-8cc8-e2d72044e6b3
md"""
**Enter Femoral Artery Segmentation Folder**

Input the name of the folder containing the SureStart scans (default is `FA_dcm`). Then click submit

$(@bind fa_folder confirm(PlutoUI.TextField(60; default = "FA_dcm")))
"""

# ╔═╡ 76557751-7e5b-4e12-ad1a-85689755ef75
fa_path = joinpath(segmentation_root, fa_folder)

# ╔═╡ 21138ade-c322-4a04-8ba3-bf5acff03eea
dcms_fa = dcmdir_parse(fa_path);

# ╔═╡ d3ca2ccf-961e-4612-bfa3-c61dbc27dcbb
md"""
# Convert DICOMs to Arrays
"""

# ╔═╡ 37a39564-c811-4b64-a76d-6071062757b1
md"""
## V1 & V2
"""

# ╔═╡ 25541b4e-7c19-44e2-a5a6-27c0b373ea9a
begin
	v1_arr = load_dcm_array(dcms_v1)
	v2_arr = load_dcm_array(dcms_v2)
end;

# ╔═╡ 60ef5850-638a-4f89-b2be-63d151e2f690
@bind z_vols PlutoUI.Slider(axes(v1_arr, 3), show_value = true, default = size(v1_arr, 3) ÷ 15)

# ╔═╡ 9a7b1a51-90a2-472d-8809-0bbdee4afa1f
let
    f = Figure(resolution = (2200, 1400))
    ax = CairoMakie.Axis(
        f[1, 1],
        title = "V1 (No Contrast)",
        titlesize = 40
    )
    heatmap!(v1_arr[:, :, z_vols], colormap = :grays)

    ax = CairoMakie.Axis(
        f[1, 2],
        title = "V2 (Contrast)",
        titlesize = 40
    )
    heatmap!(v2_arr[:, :, z_vols], colormap = :grays)
    f
end

# ╔═╡ 9ed4ce81-bcff-4279-b841-24675dc9f128
md"""
## Limb
"""

# ╔═╡ f0dc9f93-3d74-41d3-a3e9-c8f8927248b6
limb_arr = load_dcm_array(dcms_limb);

# ╔═╡ 72bdc8ea-96f9-4535-ba01-f37e9930a54b
begin
    limb_mask = copy(limb_arr)
    replace!(x -> x < -1000 ? 0 : x, limb_mask)
    limb_mask = limb_mask[:, :, end:-1:1]
	limb_mask = limb_mask .!= 0;
end;

# ╔═╡ d124f844-5079-4501-8eef-b54ce939e0a1
@bind z_limb PlutoUI.Slider(axes(limb_mask, 3), show_value = true, default = size(limb_mask, 3) ÷ 2)

# ╔═╡ 13014114-37ba-4183-8660-2b5f7d3fa74f
let
    f = Figure(resolution = (2200, 1600))
    ax = Axis(
        f[1, 1],
        title = "Limb Mask",
		titlesize = 40
    )
    heatmap!(limb_mask[:, :, z_limb], colormap = :grays)

    ax = Axis(
        f[1, 2],
        title = "Limb Mask Overlayed",
		titlesize = 40
    )
    heatmap!(v2_arr[:, :, z_limb], colormap = :grays)
    heatmap!(limb_mask[:, :, z_limb], colormap = (:jet, 0.3))
    f
end

# ╔═╡ 2a01a6c8-e4fe-483a-a304-712683abd901
md"""
## SureStart
"""

# ╔═╡ f6965577-c718-4a03-87b6-248818860f7d
ss_arr = load_dcm_array(dcms_ss);

# ╔═╡ 25a72dd0-7435-4aa9-98b0-d8a6f5ea1eed
@bind z_ss PlutoUI.Slider(axes(ss_arr, 3), show_value = true, default = size(ss_arr, 3) ÷ 2)

# ╔═╡ 36be9348-d572-4fa5-86e5-6e529f2d7092
let
    f = Figure()
    ax = Axis(
        f[1, 1],
        title = "SureStart"
    )
    heatmap!(ss_arr[:, :, z_ss], colormap = :grays)
    f
end

# ╔═╡ a2135aeb-81c2-4ac4-ad62-9409a941c18f
md"""
## Femoral Artery
"""

# ╔═╡ 0814112e-a7bc-48b2-b5a9-9b8b0abfc387
fa_arr = load_dcm_array(dcms_fa);

# ╔═╡ 0c8bdc4e-67f2-42f4-b40b-ddac9f96ff19
begin
    fa_mask = copy(fa_arr)
    replace!(x -> x < -1000 ? 0 : x, fa_mask)
    fa_mask = fa_mask[:, :, end:-1:1]
	fa_mask = fa_mask .!= 0;
end;

# ╔═╡ fc1279db-b5ce-46f0-a8fb-385e9eace71f
begin
    fa_mask_erode = zeros(size(fa_mask));
    for i in axes(fa_mask)
        fa_mask_erode[:, :, i] = erode(fa_mask[:, :, i])
    end
end

# ╔═╡ 47a7aa2c-610e-4394-8ba0-cb902cb6ed42
@bind z_fa PlutoUI.Slider(axes(fa_mask, 3), show_value = true, default = size(fa_mask, 3) ÷ 15)

# ╔═╡ 48246bdc-59e8-49aa-8785-03a064accbbd
let
    f = Figure(resolution = (2200, 2200))
    ax = CairoMakie.Axis(
        f[1, 1],
        title = "Femoral Artery Mask",
        titlesize = 40
    )
    heatmap!(fa_mask[:, :, z_fa], colormap = :grays)

    ax = CairoMakie.Axis(
        f[1, 2],
        title = "Femoral Artery Mask Eroded",
        titlesize = 40
    )
    heatmap!(fa_mask_erode[:, :, z_fa], colormap = :grays)

	ax = CairoMakie.Axis(
        f[2, 1],
        title = "Femoral Artery Mask Overlayed",
        titlesize = 40
    )
    heatmap!(v2_arr[:, :, z_fa], colormap = :grays)
    heatmap!(fa_mask[:, :, z_fa], colormap = (:jet, 0.3))

    ax = CairoMakie.Axis(
        f[2, 2],
        title = "Femoral Artery Mask Eroded",
        titlesize = 40
    )
    heatmap!(v2_arr[:, :, z_fa], colormap = :grays)
    heatmap!(fa_mask_erode[:, :, z_fa], colormap = (:jet, 0.3))
    f
end

# ╔═╡ 6bf5d4eb-423b-4c1c-870e-fe7850b23137
md"""
## Crop Arrays via Limb Mask
"""

# ╔═╡ fbc16d72-d17e-4a1b-ab38-531ef4dc9727
bounding_box_indices = find_bounding_box(limb_mask; offset = (20, 20, 5))

# ╔═╡ 993ca35e-9b88-4cbd-bdd9-79e9b01e0009
begin
	v1_crop = crop_array(v1_arr, bounding_box_indices...)
	v2_crop = crop_array(v2_arr, bounding_box_indices...)
	limb_crop = crop_array(limb_mask, bounding_box_indices...)
	fa_crop = crop_array(fa_mask_erode, bounding_box_indices...)
end;

# ╔═╡ d4e86abf-fb28-4aa9-aa84-307c974630ad
md"""
# Registration
"""

# ╔═╡ 24b1a95d-69fb-451a-90c5-d5ed61e56aeb
v2_reg = register(v1_crop, v2_crop; num_iterations = 10);

# ╔═╡ f08a4ff7-cbbf-4681-a049-bfa451cf780a
@bind z_reg PlutoUI.Slider(axes(v1_crop, 3), show_value = true, default = 182)

# ╔═╡ 049e8a67-6237-43c0-9adc-c5dfe7e4d03f
let
    f = Figure(resolution = (2200, 1400))
    ax = CairoMakie.Axis(
        f[1, 1],
        title = "Unregistered",
        titlesize = 40
    )
    heatmap!(v2_crop[:, :, z_reg] - v1_crop[:, :, z_reg])

    ax = CairoMakie.Axis(
        f[1, 2],
        title = "Registered",
        titlesize = 40
    )
	heatmap!(v2_reg[:, :, z_reg] - v1_crop[:, :, z_reg])
    f
end

# ╔═╡ 0fbad88e-7598-4416-ba4f-caab5af09bbb
md"""
# Arterial Input Function (AIF)
"""

# ╔═╡ c966dfc6-3117-4d76-9e12-129e05bbf68a
md"""
## SureStart
"""

# ╔═╡ 906f9427-4757-44d9-a957-2efd4b7f53f0
md"""
Select slice: $(@bind z1_aif PlutoUI.Slider(axes(ss_arr, 3), show_value = true, default = size(ss_arr, 3)))

Choose x location: $(@bind x1_aif PlutoUI.Slider(axes(ss_arr, 1), show_value = true, default = size(ss_arr, 1) ÷ 2))

Choose y location: $(@bind y1_aif PlutoUI.Slider(axes(ss_arr, 1), show_value = true, default = size(ss_arr, 1) ÷ 2))

Choose radius: $(@bind r1_aif PlutoUI.Slider(1:10, show_value = true))
"""

# ╔═╡ 5eb279b5-348f-4c00-bad2-c40f545739be
let
	f = Figure()
	ax = CairoMakie.Axis(
		f[1, 1],
		title = "Sure Start AIF"
	)
	heatmap!(ss_arr[:, :, z1_aif], colormap = :grays)

	# Draw circle using parametric equations
	phi = 0:0.01:2π
	circle_x = r1_aif .* cos.(phi) .+ x1_aif
	circle_y = r1_aif .* sin.(phi) .+ y1_aif
	lines!(circle_x, circle_y, label="Aorta Mask (radius $r1_aif)", color=:red, linewidth = 1)

	axislegend(ax)
	
	f
end

# ╔═╡ 7f1b44c5-924b-4541-8fff-e1298f9a9ef0
md"""
## V2 (AIF)
"""

# ╔═╡ 69bbc077-2523-47a1-8c48-b0dc5c8ef0c2
md"""
Select slice: $(@bind z2_aif PlutoUI.Slider(axes(v2_reg, 3), show_value = true))

Choose x location: $(@bind x2_aif PlutoUI.Slider(axes(v2_reg, 1), show_value = true, default = size(v2_reg, 1) ÷ 2))

Choose y location: $(@bind y2_aif PlutoUI.Slider(axes(v2_reg, 1), show_value = true, default = size(v2_reg, 1) ÷ 2))

Choose radius: $(@bind r2_aif PlutoUI.Slider(1:10, show_value = true))
"""

# ╔═╡ e9dad16b-07bc-4b87-be6b-959b078a5ba7
let
	f = Figure()
	ax = CairoMakie.Axis(
		f[1, 1],
		title = "V2 AIF"
	)
	heatmap!(v2_reg[:, :, z2_aif], colormap = :grays)

	# Draw circle using parametric equations
	phi = 0:0.01:2π
	circle_x = r2_aif .* cos.(phi) .+ x2_aif
	circle_y = r2_aif .* sin.(phi) .+ y2_aif
	lines!(circle_x, circle_y, label="Femoral Artery Mask (radius $r2_aif)", color=:red, linewidth = 0.5)

	axislegend(ax)
	
	f
end

# ╔═╡ 1f411b88-7447-4281-a17f-22586aa9f503
aif_vec_ss = compute_aif(ss_arr, x1_aif, y1_aif, r1_aif)

# ╔═╡ e3999ac3-5bb1-443f-916b-1f40ff080db8
aif_vec_v2 = compute_aif(v2_reg, x2_aif, y2_aif, r2_aif, z2_aif)

# ╔═╡ 7cfa63ad-2365-4256-a75d-251e1033883d
aif_vec_gamma = [aif_vec_ss..., aif_vec_v2]

# ╔═╡ 1e21f95a-bc8a-492f-9a56-820dd3b3d066
md"""
# Time Attenuation Curve
"""

# ╔═╡ 0ba3a947-23be-49ca-ac2c-b0d295d096e9
md"""
## Extract SureStart Times
"""

# ╔═╡ 731d29ce-4dee-418a-95f7-42aacc073ae7
begin
	time_vector_ss = scan_time_vector(dcms_ss)
	time_vector_ss_rel = time_vector_ss .- time_vector_ss[1]
end

# ╔═╡ 71f85cd3-020b-46bb-8dd4-483f6125bf38
begin
	time_vector_v2 = scan_time_vector(dcms_v2)
	time_vector_v2_rel = time_vector_v2 .- time_vector_v2[1]
end

# ╔═╡ 692d455a-a746-4913-a7ce-5fd30d6718ae
delta_time = time_vector_v2[length(time_vector_v2) ÷ 2] - time_vector_ss[end]

# ╔═╡ 2975eb4b-3dbf-4201-8d2a-94d95c417570
time_vec_gamma = [time_vector_ss_rel..., delta_time + time_vector_ss_rel[end]]

# ╔═╡ e385d115-47e4-4a59-a6d0-6ea95455e901
md"""
## Gamma Variate
"""

# ╔═╡ e87721fa-5731-4a3e-bd8d-a17dc8fdeffc
begin
	# Upper and Lower Bounds
	lb = [-100.0, 0.0]
	ub = [100.0, 200.0]

	baseline_hu = mean(aif_vec_gamma[1:3])
	p0 = [0.0, baseline_hu]  # Initial guess (0, blood pool offset)

	time_vec_end, aif_vec_end = time_vec_gamma[end], aif_vec_gamma[end]
end

# ╔═╡ 93002fa1-995c-4306-a6a6-264be2d939d1
fit = gamma_curve_fit(time_vec_gamma, aif_vec_gamma, time_vec_end, aif_vec_end, p0; lower_bounds = lb, upper_bounds = ub)

# ╔═╡ 54916f43-c05a-4ff3-bd62-ba715f0b6937
opt_params = coef(fit)

# ╔═╡ fc43feee-9d9a-4af6-a76a-7dfbb927c0ae
begin
	x_fit = range(start = minimum(time_vec_gamma), stop = maximum(time_vec_gamma), length=500)
	y_fit = gamma(x_fit, opt_params, time_vec_end, aif_vec_end)
	dense_y_fit_adjusted = max.(y_fit .- baseline_hu, 0)
end

# ╔═╡ 367a0c68-081f-4a57-9a26-9d4094b8f1df
area_under_curve = trapz(x_fit, dense_y_fit_adjusted)

# ╔═╡ e4ed2262-1d71-47ec-8256-6d5c2f8ad376
times = collect(range(time_vec_gamma[1], stop=time_vec_end, length=round(Int, maximum(time_vec_gamma))))

# ╔═╡ baaa5740-d6e6-405a-8e14-fa5b0ef7050b
begin
	input_conc = area_under_curve ./ (time_vec_gamma[19] - times[4])
	if length(aif_vec_gamma) > 2
		input_conc = mean([aif_vec_gamma[end], aif_vec_gamma[end-1]])
	end
	input_conc
end

# ╔═╡ c44b2487-bcd2-43f2-af89-2e3b0e1a54e8
let
	f = Figure()
	ax = Axis(
		f[1, 1],
		xlabel = "Time Point",
		ylabel = "Intensity (HU)",
		title = "Fitted AIF Curve"
	)
	
	scatter!(time_vec_gamma, aif_vec_gamma, label="Data Points")
	lines!(x_fit, y_fit, label="Fitted Curve", color = :red)
	scatter!(time_vec_gamma[end-1], aif_vec_gamma[end-1], label = "Trigger")
	scatter!(time_vec_gamma[end], aif_vec_gamma[end], label = "V2")
	
	axislegend(ax, position=:lt)

	# Create the AUC plot
	time_temp = range(time_vec_gamma[3], stop=time_vec_gamma[end], length=round(Int, maximum(time_vec_gamma) * 1))
	auc_area = gamma(time_temp, opt_params, time_vec_end, aif_vec_end) .- baseline_hu
	
	# Create a denser AUC plot
	n_points = 1000  # Number of points for denser interpolation
	time_temp_dense = range(time_temp[1], stop=time_temp[end], length=n_points)
	auc_area_dense = gamma(time_temp_dense, opt_params, time_vec_end, aif_vec_end) .- baseline_hu

	for i = 1:length(auc_area_dense)
	    lines!(ax, [time_temp_dense[i], time_temp_dense[i]], [baseline_hu, auc_area_dense[i] + baseline_hu], color=:cyan, linewidth=1, alpha=0.2)
	end

	f
end

# ╔═╡ 5aecb6b9-a813-4cf8-8a7f-2da4a19a052e
md"""
# Whole Organ Perfusion
"""

# ╔═╡ d90057db-c68d-4b70-9247-1098bf129783
md"""
## Prepare Perfusion Details
"""

# ╔═╡ 140c1343-2a6e-4d4f-a3db-0d608d7e885c
begin
	header = dcms_v1[1].meta
	voxel_size = get_voxel_size(header)
end

# ╔═╡ 9a5dfd0a-a27a-444e-9963-621a89170652
tissue_rho = 1.053 # tissue density : g/cm^2

# ╔═╡ 3631e518-6258-4cb7-ad61-8d7975f2da67
organ_mass = (sum(limb_crop) * tissue_rho * voxel_size[1] * voxel_size[2] * voxel_size[3]) / 1000 # g

# ╔═╡ 89f21b6f-ecbc-475d-bf9e-408fcbc7f45a
delta_hu = mean(v2_reg[limb_crop]) - mean(v1_crop[limb_crop])

# ╔═╡ d1fb1e4d-e0b5-48ce-82bd-69b3d91f2b2a
organ_vol_inplane =  voxel_size[1] * voxel_size[2] / 1000

# ╔═╡ 7b841262-0031-4a44-b17c-f5059b0f59a0
v1_mass = sum(v1_crop[limb_crop]) * organ_vol_inplane

# ╔═╡ 1b1d2d32-3411-4ecb-8558-a3bf5af10bd8
v2_mass = sum(v2_reg[limb_crop]) * organ_vol_inplane

# ╔═╡ 4cf12eb6-2739-497c-9171-5f2f557c60d0
flow  = (1 / input_conc) * ((v2_mass - v1_mass) / (delta_time / 60)) # mL/min

# ╔═╡ 72ddceea-6a7d-4b05-99dd-3313ce0eb840
flow_map = (v2_reg - v1_crop) ./ (mean(v2_reg[limb_crop]) - mean(v1_crop[limb_crop])) .* flow; # mL/min/g, voxel-by-voxel blood perfusion of organ of interest

# ╔═╡ a2aeaa04-3097-4dd0-8bab-5c98b74514b3
@bind z6 PlutoUI.Slider(axes(flow_map, 3), show_value = true)

# ╔═╡ 283c0ee5-0321-4f5d-9792-d593f49cafc1
heatmap(flow_map[:, :, z6])

# ╔═╡ ed06f353-fdcf-47af-94be-52c2e11957f4
perf_map = flow_map ./ organ_mass;

# ╔═╡ 15b31020-253d-46e6-a985-f2043c71e1fc
perf = (flow / organ_mass, std(perf_map[limb_crop]))

# ╔═╡ 1befeeba-40bb-4310-8441-6609fc82dc21
md"""
## Results
"""

# ╔═╡ ac0e22da-0617-434c-b6ed-88c5f688f1c1
heart_rate = round(1 / (mean(diff(time_vec_gamma)) / 60))

# ╔═╡ c0dcbc56-be6e-47ba-b3e8-9f12ec469e4b
col_names = [
    "perfusion",
    "perfusion_std",
    "perfusion_ref",
    "flow",
    "flow_std",
    "delta_time",
    "mass",
    "delta_hu",
    "heart_rate"
]

# ╔═╡ e79e2a10-78d0-4571-b601-daf9d164b0c9
col_vals = [
    perf[1],
    perf[2],
    length(perf) == 3 ? perf[3] : missing,
    perf[1] * organ_mass,
    perf[2] * organ_mass,  
    delta_time,
    organ_mass,
    delta_hu,
    heart_rate
]

# ╔═╡ a861ded4-dbcf-4f06-a1b4-17d8f8ddf214
df = DataFrame(parameters = col_names, values = col_vals)

# ╔═╡ Cell order:
# ╠═eeba971b-c64e-4195-95ca-5cf2ae5ac590
# ╠═0129d839-fde4-46bf-a2e1-beb79fdd2cab
# ╟─b4252854-a892-48d1-9c67-4b4ac3b74ded
# ╟─6fa28ef7-8e95-43af-9ef1-9fb549590bf7
# ╟─aa13d033-c4a1-455c-8fa2-5cfc5a51b9c2
# ╟─a830eebb-faf8-492b-ac42-2109e5173482
# ╟─42ff7c1a-42ce-4b1c-b1c0-3d8882bd8340
# ╟─87284291-da14-4a86-8af1-2dcd8d845eee
# ╠═c84f0933-8354-4f89-ab16-032cdebb1101
# ╠═26b7a474-0653-4ff4-9455-df1448623fee
# ╠═185d08b1-a1f7-4bf2-b0c3-84af66dcc415
# ╠═5e985484-17d3-47b9-b764-c0c714cc0df1
# ╠═baeb5520-a946-4ce5-9d66-c0407d47cca2
# ╠═5e1c9271-f4cf-4bbf-bf66-e8f12debf08a
# ╟─82a0af24-d4a9-461b-b054-90fe37fa61e5
# ╟─43c9c836-2492-431a-9664-d4f900279b2e
# ╠═7f54d3c0-945e-4bc3-b2de-f37d93208963
# ╠═0c7580e8-3e49-44bf-b53e-5070be62e722
# ╟─795e6621-0df8-49e5-973a-ada9b37e451f
# ╟─9e791737-a82f-4b07-b6da-fe8d4af1bfe1
# ╠═10b527a0-18d9-4d59-8556-fee3b2c90fe2
# ╟─9d76a68a-d983-41bb-90c8-02853fa5f37f
# ╟─bec6e715-47f9-42b4-9ce7-6df632b8ff54
# ╠═be43dea5-69a4-449c-9423-864c53e728c0
# ╠═320330e3-7309-48aa-ac4b-123e9c23795a
# ╟─b458422d-0949-4581-9c68-9872ba67e26e
# ╟─ca6f06be-b7e9-4cc8-8cc8-e2d72044e6b3
# ╠═76557751-7e5b-4e12-ad1a-85689755ef75
# ╠═21138ade-c322-4a04-8ba3-bf5acff03eea
# ╟─d3ca2ccf-961e-4612-bfa3-c61dbc27dcbb
# ╟─37a39564-c811-4b64-a76d-6071062757b1
# ╠═25541b4e-7c19-44e2-a5a6-27c0b373ea9a
# ╟─60ef5850-638a-4f89-b2be-63d151e2f690
# ╟─9a7b1a51-90a2-472d-8809-0bbdee4afa1f
# ╟─9ed4ce81-bcff-4279-b841-24675dc9f128
# ╠═f0dc9f93-3d74-41d3-a3e9-c8f8927248b6
# ╠═72bdc8ea-96f9-4535-ba01-f37e9930a54b
# ╟─d124f844-5079-4501-8eef-b54ce939e0a1
# ╟─13014114-37ba-4183-8660-2b5f7d3fa74f
# ╟─2a01a6c8-e4fe-483a-a304-712683abd901
# ╠═f6965577-c718-4a03-87b6-248818860f7d
# ╟─25a72dd0-7435-4aa9-98b0-d8a6f5ea1eed
# ╟─36be9348-d572-4fa5-86e5-6e529f2d7092
# ╟─a2135aeb-81c2-4ac4-ad62-9409a941c18f
# ╠═0814112e-a7bc-48b2-b5a9-9b8b0abfc387
# ╠═0c8bdc4e-67f2-42f4-b40b-ddac9f96ff19
# ╠═fc1279db-b5ce-46f0-a8fb-385e9eace71f
# ╟─47a7aa2c-610e-4394-8ba0-cb902cb6ed42
# ╟─48246bdc-59e8-49aa-8785-03a064accbbd
# ╟─6bf5d4eb-423b-4c1c-870e-fe7850b23137
# ╠═fbc16d72-d17e-4a1b-ab38-531ef4dc9727
# ╠═993ca35e-9b88-4cbd-bdd9-79e9b01e0009
# ╟─d4e86abf-fb28-4aa9-aa84-307c974630ad
# ╠═24b1a95d-69fb-451a-90c5-d5ed61e56aeb
# ╟─f08a4ff7-cbbf-4681-a049-bfa451cf780a
# ╟─049e8a67-6237-43c0-9adc-c5dfe7e4d03f
# ╟─0fbad88e-7598-4416-ba4f-caab5af09bbb
# ╟─c966dfc6-3117-4d76-9e12-129e05bbf68a
# ╟─906f9427-4757-44d9-a957-2efd4b7f53f0
# ╟─5eb279b5-348f-4c00-bad2-c40f545739be
# ╟─7f1b44c5-924b-4541-8fff-e1298f9a9ef0
# ╟─69bbc077-2523-47a1-8c48-b0dc5c8ef0c2
# ╟─e9dad16b-07bc-4b87-be6b-959b078a5ba7
# ╠═1f411b88-7447-4281-a17f-22586aa9f503
# ╠═e3999ac3-5bb1-443f-916b-1f40ff080db8
# ╠═7cfa63ad-2365-4256-a75d-251e1033883d
# ╟─1e21f95a-bc8a-492f-9a56-820dd3b3d066
# ╟─0ba3a947-23be-49ca-ac2c-b0d295d096e9
# ╠═731d29ce-4dee-418a-95f7-42aacc073ae7
# ╠═71f85cd3-020b-46bb-8dd4-483f6125bf38
# ╠═692d455a-a746-4913-a7ce-5fd30d6718ae
# ╠═2975eb4b-3dbf-4201-8d2a-94d95c417570
# ╟─e385d115-47e4-4a59-a6d0-6ea95455e901
# ╠═e87721fa-5731-4a3e-bd8d-a17dc8fdeffc
# ╠═93002fa1-995c-4306-a6a6-264be2d939d1
# ╠═54916f43-c05a-4ff3-bd62-ba715f0b6937
# ╠═fc43feee-9d9a-4af6-a76a-7dfbb927c0ae
# ╠═367a0c68-081f-4a57-9a26-9d4094b8f1df
# ╠═e4ed2262-1d71-47ec-8256-6d5c2f8ad376
# ╠═baaa5740-d6e6-405a-8e14-fa5b0ef7050b
# ╟─c44b2487-bcd2-43f2-af89-2e3b0e1a54e8
# ╟─5aecb6b9-a813-4cf8-8a7f-2da4a19a052e
# ╟─d90057db-c68d-4b70-9247-1098bf129783
# ╠═140c1343-2a6e-4d4f-a3db-0d608d7e885c
# ╠═9a5dfd0a-a27a-444e-9963-621a89170652
# ╠═3631e518-6258-4cb7-ad61-8d7975f2da67
# ╠═89f21b6f-ecbc-475d-bf9e-408fcbc7f45a
# ╠═d1fb1e4d-e0b5-48ce-82bd-69b3d91f2b2a
# ╠═7b841262-0031-4a44-b17c-f5059b0f59a0
# ╠═1b1d2d32-3411-4ecb-8558-a3bf5af10bd8
# ╠═4cf12eb6-2739-497c-9171-5f2f557c60d0
# ╠═72ddceea-6a7d-4b05-99dd-3313ce0eb840
# ╟─a2aeaa04-3097-4dd0-8bab-5c98b74514b3
# ╠═283c0ee5-0321-4f5d-9792-d593f49cafc1
# ╠═ed06f353-fdcf-47af-94be-52c2e11957f4
# ╠═15b31020-253d-46e6-a985-f2043c71e1fc
# ╟─1befeeba-40bb-4310-8441-6609fc82dc21
# ╠═ac0e22da-0617-434c-b6ed-88c5f688f1c1
# ╠═c0dcbc56-be6e-47ba-b3e8-9f12ec469e4b
# ╠═e79e2a10-78d0-4571-b601-daf9d164b0c9
# ╠═a861ded4-dbcf-4f06-a1b4-17d8f8ddf214
