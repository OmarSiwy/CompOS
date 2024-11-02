from conan import ConanFile, tools
from conan.tools.files import copy
from conan.errors import ConanException, ConanInvalidConfiguration
import os
import shutil

class CompOSConan(ConanFile):
    name = "compos"
    version = "1.0.0"
    license = "MIT"
    author = "Omar El-Sawy <ok.elsawy@gmail.com>"
    url = "https://github.com/OmarSiwy/CompOS"
    description = "A Compile-Time Based Real-Time Operating System designed for low-latency task switching"
    topics = ("zig", "c", "library", "embedded", "RTOS")
    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "compile_target": ["STM32F103", "STM32F407", "STM32F030", "STM32H743", "STM32L476", "STM32F303", "testing"],
        "optimize": ["Debug", "ReleaseFast", "ReleaseSafe", "ReleaseSmall"]
    }
    default_options = {
        "shared": False,
        "compile_target": "testing",
        "optimize": "ReleaseFast"
    }
    exports_sources = "src/*", "inc/*", "build/*", "build.zig", "build.zig.zon"
    no_copy_source = True

    def configure(self):
        """
        Makes sure the commands are valid
        """
        if not self.options.compile_target:
            raise ConanInvalidConfiguration("The 'compile_target' option must be specified.")
        if not self.options.optimize:
            raise ConanInvalidConfiguration("The 'optimize' option must be specified.")

    def build(self):
        """
        Moves Folders/Files to the correct location then runs the build command
        """
        shutil.copy(os.path.join(self.source_folder, "build.zig"), self.build_folder)
        shutil.copy(os.path.join(self.source_folder, "build.zig.zon"), self.build_folder)
        shutil.copytree(os.path.join(self.source_folder, "build"), os.path.join(self.build_folder, "build"), dirs_exist_ok=True)
        shutil.copytree(os.path.join(self.source_folder, "src"), os.path.join(self.build_folder, "src"), dirs_exist_ok=True)
        shutil.copytree(os.path.join(self.source_folder, "inc"), os.path.join(self.build_folder, "inc"), dirs_exist_ok=True)


        # Last Check on Options
        lib_type = "Shared" if self.options.shared else "Static"
        compile_target = self.options.compile_target
        optimize = self.options.optimize

        # Construct and run the Zig build command
        zig_build_cmd = (
            f"zig build -Doptimize={optimize} "
            f"-DLibrary_Type={lib_type} "
            f"-DCompile_Target={compile_target}"
        )

        result = self.run(zig_build_cmd, ignore_errors=True, cwd=self.build_folder)
        
        if result != 0:
            self.output.error("Zig build failed. Check your settings or dependencies.")
            raise ConanException(f"Zig build failed with exit code {result}. Command: {zig_build_cmd}")

    def package(self):
        build_folder = "zig-out"
        copy(self, "*.a", src=f"{build_folder}/lib", dst=os.path.join(self.package_folder, "lib"), keep_path=False)
        copy(self, "*.so", src=f"{build_folder}/lib", dst=os.path.join(self.package_folder, "lib"), keep_path=False)
        copy(self, "*.h", src="inc", dst=os.path.join(self.package_folder, "include"), keep_path=False)

    def package(self):
        build_folder = os.path.join(self.build_folder, "zig-out")
        copy(self, "*.a", src=os.path.join(build_folder, "lib"), dst=os.path.join(self.package_folder, "lib"), keep_path=False)
        copy(self, "*.so", src=os.path.join(build_folder, "lib"), dst=os.path.join(self.package_folder, "lib"), keep_path=False)
        copy(self, "*.h", src=os.path.join(self.source_folder, "inc"), dst=os.path.join(self.package_folder, "include"), keep_path=False)

    def package_info(self):
        # Export library details for consumers
        self.cpp_info.libs = ["CompOS"]
        self.cpp_info.includedirs = ["inc"]
