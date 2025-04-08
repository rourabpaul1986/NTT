# Load Vivado settings
#source /tools/Xilinx/Vivado/2018.3/settings64.sh
#vivado -mode tcl

set current_dir [pwd]
set project_name "fntt"
set project_dir "./${project_name}_project"

# Check if required arguments are provided
if {[llength $argv] < 2} {
    puts "Usage: vivado -mode batch -source run_vivado.tcl <q_value> <n_value>"
    exit 1
}

# Get command-line arguments
set q [lindex $argv 0]
set n [lindex $argv 1]

# Compute log2(q) and round up
set logq [expr {int(ceil(log($q) / log(2)))}]

# Print received values
puts "Received modulus (q): $q"
puts "Received degree (n): $n"
puts "Memory register width (logq): $logq"

# Delete previous project directory
if {[file exists $project_dir]} {
    puts "Deleting previous project directory: $project_dir"
    file delete -force $project_dir
}

# Create new project
create_project $project_name $project_dir -part xc7a100tcsg324
set_property target_language VHDL [current_project]
add_files "./src/"

# Define memory and coefficient file lists
set memory [list w_mem]
set coe_file [list w_mem]

# Iterate over both lists to configure memory blocks
for {set i 0} {$i < [llength $memory]} {incr i} {
    set mem [lindex $memory $i]
    set coe "$current_dir/[lindex $coe_file $i].coe"
    set xci_file "$project_dir/$project_name.srcs/sources_1/ip/$mem/$mem.xci"

    puts "\n============================"
    puts "Iteration: [expr $i + 1] of [llength $memory]"
    puts "Configuring Memory Block: $mem"
    puts "Using COE file: $coe"
    puts "XCI File Path: $xci_file"
    puts "============================\n"

    # Ensure the COE file exists
    if {![file exists $coe]} {
        puts "Error: COE file not found at $coe"
        continue
    }

    # Create the IP core if it does not exist
    if {[llength [get_ips $mem]] == 0} {
        puts "Creating IP Core: $mem"
        create_ip -name dist_mem_gen -vendor xilinx.com -library ip -version 8.0 -module_name $mem
    }

    # Refresh IP catalog
    update_ip_catalog
    set ip_obj [get_ips $mem]

    if {$ip_obj eq ""} {
        puts "Error: IP core $mem not found! Skipping..."
        continue
    }

    # Set properties for the IP core
    puts "Setting properties for $mem..."
    set_property -dict [list \
        CONFIG.depth $n \
        CONFIG.data_width $logq \
        CONFIG.Component_Name $mem \
        CONFIG.memory_type {rom} \
        CONFIG.input_options {registered} \
        CONFIG.coefficient_file $coe] $ip_obj

    puts "IP configuration updated successfully for $mem!"

    # Generate necessary targets for the IP
    generate_target {instantiation_template} [get_ips $mem]
    generate_target all [get_ips $mem]

    # Ensure the .xci file is properly referenced
    if {![file exists $xci_file]} {
        puts "Error: XCI file for $mem not found! Skipping synthesis."
        continue
    }

    # Clear previous caches
    catch { reset_project }
    catch { config_ip_cache -export [get_ips -all $mem] }

    # Export IP user files
    export_ip_user_files -of_objects [get_files $xci_file] \
        -no_script -sync -force -quiet

    # Create synthesis run for the memory block
    create_ip_run [get_ips $mem]

    # Launch synthesis and wait for it to complete
    launch_runs ${mem}_synth_1
    wait_on_run ${mem}_synth_1

    # Export simulation files
    export_simulation -of_objects [get_files $xci_file] \
        -directory $project_dir/$project_name.ip_user_files/sim_scripts \
        -ip_user_files_dir $project_dir/$project_name.ip_user_files \
        -ipstatic_source_dir $project_dir/$project_name.ip_user_files/ipstatic \
        -lib_map_path [list {modelsim=$project_dir/$project_name.cache/compile_simlib/modelsim} \
                            {questa=$project_dir/$project_name.cache/compile_simlib/questa} \
                            {ies=$project_dir/$project_name.cache/compile_simlib/ies} \
                            {xcelium=$project_dir/$project_name.cache/compile_simlib/xcelium} \
                            {vcs=$project_dir/$project_name.cache/compile_simlib/vcs} \
                            {riviera=$project_dir/$project_name.cache/compile_simlib/riviera}] \
        -use_ip_compiled_libs -force -quiet

    puts "IP generation completed successfully for $mem!"
}

puts "\nAll memory blocks configured and generated successfully!"


set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse "./tb/"
update_compile_order -fileset sim_1
##############simulation#############
launch_simulation
add_wave {{/fntt_tb/uut/poly_mem_DUT/ram}} 
relaunch_sim
run 10 us
#################################
# Set top module and save project
set_property top fntt [current_fileset]
#close_project
# Open Vivado GUI
start_gui

