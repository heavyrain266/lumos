package lumos

import "core:log"

import vk "vendor:vulkan"

Instance :: struct {
	handle: vk.Instance,
}

Instance_Info :: struct {
	app_name: cstring,
	engine_name: cstring,

	proc_addr: rawptr,
}

@(private) vk_check :: proc(result: vk.Result, loc := #caller_location) {
	if result != .SUCCESS {
		log.panicf("{} in {}", result, loc)
	}
}

init_instance :: proc(instance_info: Instance_Info) -> (instance: Instance) {
	vk.load_proc_addresses_global(instance_info.proc_addr)

	vk_check(vk.CreateInstance(&vk.InstanceCreateInfo{
		sType = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &vk.ApplicationInfo{
			sType = .APPLICATION_INFO,
			pApplicationName = instance_info.app_name,
			pEngineName = instance_info.engine_name,
		},
		enabledLayerCount = 2,
		ppEnabledLayerNames = raw_data([]cstring{
			"VK_LAYER_KHRONOS_validation",
			"VK_LAYER_KHRONOS_shader_object",
		}),
		enabledExtensionCount = 2,
		ppEnabledExtensionNames = raw_data([]cstring{
			vk.KHR_SURFACE_EXTENSION_NAME,
			vk.KHR_WIN32_SURFACE_EXTENSION_NAME,

			vk.EXT_DEBUG_UTILS_EXTENSION_NAME,
		})}, nil, &instance.handle
	))

	vk.load_proc_addresses_instance(instance.handle)

	return instance
}

destroy_instance :: proc(instance: vk.Instance) {
	vk.DestroyInstance(instance, nil)
}
