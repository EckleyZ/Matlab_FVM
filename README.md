# Matlab FVM
 
This project was an attempt to apply the finite volume method (FVM) in MATLAB to solve fluid flows. The majority of the work was completed over the summer of 2021 and is essentially finished. The initial goal was to use FVM to solve the internal ballistics of a Solid Rocket Booster (SRB), but I had some difficulty creating an adaptive mesh to change with the port geometry of the motor. 

SRBs work by molding a solid propellant around a central cutout called the port. This port can havea large variety of shapes that greatly impact the thrust curve of the motor. By changing the internal geometry of the port a very unique thrust curve can be created to fit nearly any vehicle. An image of different port shapes and their respective trhust curves is included below:

<p align="center">
    <img width="750" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.stack.imgur.com%2FPzDnY.gif&f=1&nofb=1" alt="Port geomtries with thrust curves">
</p>

However, the motor can't be infinitely scaled to generate huge amounts of thrust and when the conditions of the motor before the nozzle get too intense the performance can suffer. Towards the end of the motor where the grain burns quicker due to the hgher pressure. In addition, the high pressure, high temperatrue gasses moving through the port can erode the grain and cause it to burn faster or even have small pieces separate from the main grain. These phenomenon make the internal ballistics of an SRB complex to model. This project was initially started to see how the erosive burning and varying burn rates would affect performance.

Instead, I focused on applying FVM to solve fluid flows and left the changing mesh for later. Early in the Fall of 2021 I figured out how to make the mesh adjust to the new geometry of the port by modeling the nodes and elements as a spring damper system. The outer nodes would move to fit the new geometry and the inner nodes would reposition themselves to keep a similar mesh structure. Problems would occur using that method towards the end of the burn when the port geometry was essentially circular. Elements would become compressed in areas that had a high initial curvature. Other methods were looked into but my classes prevented me from working on teh project mush outside of class.

<p align="center">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/CroppedMeshTest.gif" width="600">
</p>

A similar mesh was created for the fluid flow solution using the built in functions from MATLAB's PDE toolbox. The meshes were fairly customizable and allowed for easy creation of new geomtry if you're willing to hard code it. The two meshes shown below are the lowest and highest resolution meshes I coded for. The mesh on the left is the lower resolution and due to the low resolution the top corner of the wedge geoemtry has been cut to a flat surface. On the right is the higher resolution mesh. This mesh was rarely used as the number of cells is immense.

<p align="center">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/DiamondWedge1.jpg" width="300">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/DiamondWedge7.jpg" width="300">
</p>

A mesh with varying cell size could be created to reduce calculation time by only having high cell counts in the areas of interest. Below is a mesh displaying these qualities. The geometry is supposed to be the SR-71 Blackbird. The solution from this mesh will be shown later.

<p align="center">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/Blackbirdmesh.jpg" width="500">
</p>

FVM was used first used to solve for water sloshing around in a box so I could get the hang of the process. Shortly after that was completed I began applying FVM to the inviscid compressible Navier-Stokes equations. Those equations are included below:

<p align="center">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/Equations.png" width="600">
</p>

The properties from each of the equations above were split into two matrices Fx and Fy. These matrices contained the properties described in the equations for each of the cells. The Fx and Fy matrices were repeated 3 layers deep to more easily compare the conditions of the cell with the conditions of the neighboring cells. An example of the Fx matrix is shown below with some labels to indicate what each dimension includes.

<p align="center">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/FluxMatrix.png" height="400">
    <img src="https://github.com/EckleyZ/Matlab_FVM/blob/main/Images/FluxArrays.png" height="250">
</p>


