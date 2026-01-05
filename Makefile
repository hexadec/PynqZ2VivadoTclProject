project_name := project_2
vivado_folder := ~/Software/AMD/2025.2/Vivado/bin

all: clean build

build: script.tcl
	@echo Building with Vivado...
	${vivado_folder}/vivado -mode batch -source script.tcl -verbose
    
clean:
	@echo Removing generated files from project folder
	rm -rf ${project_name}.cache ${project_name}.gen ${project_name}.hw ${project_name}.srcs
	rm -rf ${project_name}.ip_user_files ${project_name}.runs ${project_name}.sim
	rm -rf block_design .Xil NA
	rm -f ${project_name}.xpr
	rm -f vivado*.log vivado*.jou
    
