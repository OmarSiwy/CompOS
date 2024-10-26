from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake
from conan.tools.files import copy
import os

class A_RTOS_M(ConanFile):
    name = "a_rtos_m"
    version = "1.0.0"
    license = "MIT"  # Replace with your project's license
    author = "Your Name <ok.elsawy@gmail.com>"
    url = "https://github.com/OmarSiwy/A-RTOS-M"  # Replace with your repo URL
    description = "A Compile-Time Based Real-Time Operating System designed for low-latency task switching"
    topics = ("zig", "c", "library")
    settings = "os", "arch", "compiler", "build_type"
    exports_sources = "src/*", "inc/*", "tests/*", "tools/*", "build.zig", "Doxyfile"
    options = {
        "shared": [True, False],
        "compile_target": ["STM32F103", "STM32F407", "STM32F030", "STM32H743", "STM32L476", "STM32F303", "testing"],
    }
    default_options = {
        "shared": True,
    }
    requires = []  # Add dependencies if needed, like fmt, or other libraries

    def build(self):
        # Validate that compile_target is provided
        if not self.options.compile_target:
            raise ConanInvalidConfiguration("The 'compile_target' option must be specified.")
        
        # Determine optimization level and library type
        optimize = "ReleaseFast" if self.settings.build_type == "Release" else "Debug"
        lib_type = "Shared" if self.options.shared else "Static"
        compile_target = self.options.compile_target  # User-specified compile target

        # Run Zig build command to compile the library
        self.run(f"zig build -DOptimization={optimize} -DLibrary_Type={lib_type} -DCompile_Target={compile_target}")

    def package(self):
        # Copy the resulting binaries to the package folder
        build_folder = "zig-out"  # Adjust if Zig's output directory is different
        copy(self, "*.so", src=build_folder, dst=os.path.join(self.package_folder, "lib"))
        copy(self, "*.a", src=build_folder, dst=os.path.join(self.package_folder, "lib"))
        copy(self, "*.h", src="inc", dst=os.path.join(self.package_folder, "include"))
        
    def package_info(self):
        # Define library information for consumers
        self.cpp_info.libs = ["A-RTOS-M"]
