{ inputs, system ? "x86_64-linux", ... }:

# ROS 2 development environment from nix-ros-overlay.
#
#   devshell ros                 (or: nix develop /etc/nixos#ros)
#   ros2 launch demo_nodes_cpp talker_listener_launch.xml
#
# Uses nix-ros-overlay's own pinned nixpkgs (not the system one) so the
# ROS binary caches from shared/modules/ros.nix actually get hits.

let
  # Jazzy = LTS until 2029. Lyrical (newer LTS) is also available in the
  # overlay; switch here, or copy this file to ros-lyrical.nix to have both.
  rosDistro = "jazzy";

  pkgs = import inputs.nix-ros-overlay.inputs.nixpkgs {
    inherit system;
    overlays = [ inputs.nix-ros-overlay.overlays.default ];
  };

  ros = pkgs.rosPackages.${rosDistro};
in
pkgs.mkShell {
  name = "ros2-${rosDistro}-dev-shell";

  packages = [
    pkgs.colcon

    (ros.buildEnv {
      # Lets colcon-built workspaces overlay on top of this environment.
      underlay = true;
      paths = with ros; [
        desktop          # ros_core + rviz2, rqt, demos, tutorials
        ament-cmake-core
        python-cmake-module
      ];
    })
  ];

  shellHook = ''
    echo
    echo "ROS 2 ${rosDistro} development environment"
    echo "--------------------------------"
    echo
    echo "Quick test:"
    echo "  ros2 launch demo_nodes_cpp talker_listener_launch.xml"
    echo
    echo "Build a workspace:"
    echo "  colcon build --symlink-install"
    echo "  source install/setup.bash"
    echo
    echo "--------------------------------"
    echo
  '';
}
