# Matlab FVM
 
This project was an attempt to apply the finite volume method (FVM) in MATLAB to solve fluid flows. The majority of the work was completed over the summer of 2021 and is essentially finished. The initial goal was to use FVM to solve the internal ballistics of a Solid Rocket Booster (SRB), but I had some difficulty creating an adaptive mesh to change with the port geometry of the motor. 

SRBs work by molding a solid propellant around a central cutout called the port. This port can havea large variety of shapes that greatly impact the thrust curve of the motor. By changing the internal geometry of the port a very unique thrust curve can be created to fit nearly any vehicle. An image of different port shapes and their respective trhust curves is included below:

<p align="center">
    <img width="750" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.stack.imgur.com%2FPzDnY.gif&f=1&nofb=1" alt="Port geomtries with thrust curves">
</p>

However, the motor can't be infinitely scaled to generate huge amounts of thrust and when the conditions of the motor before the nozzle get too intense the performance can suffer. Towards the end of the motor where the grain burns quicker due to the hgher pressure. In addition, the high pressure, high temperatrue gasses moving through the port can erode the grain and cause it to burn faster or even have small pieces separate from the main grain. These phenomenon make the internal ballistics of an SRB complex to model. This project was initially started to see how the erosive burning and varying burn rates would affect performance.

Instead, I focused on applying FVM to solve fluid flows and left the changing mesh for later. Early in the Fall of 2021 I figured out how to make the mesh adjust to the new geometry of the port by modeling the nodes and elements as a spring damper system. The outer nodes would move to fit the new geometry and the inner nodes would reposition themselves to keep a similar mesh structure. Problems would occur using that method towards the end of the burn when the port geometry was essentially circular. Elements would become compressed in areas that had a high initial curvature. Other methods were looked into but my classes prevented me from working on teh project mush outside of class.

<p align="center">
    <img src="https://github.com/EckleyZ/MatlabFiniteVolumeMethod/blob/main/Images/CroppedMeshTest.gif" width="600">
</p>

FVM was used first used to solve for water sloshing around in a box so I could get the hang of the process. Shortly after that was completed I began applying FVM to the inviscid compressible Navier-Stokes equations. Those equations are included below:

<p align="center">
    <img src="/Images/equations.png" alt="Equations" title="Inviscid compressible Navier-Stokes equations">
    <img width="750" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.stack.imgur.com%2FPzDnY.gif&f=1&nofb=1" alt="Port geomtries with thrust curves">
</p>

The properties from each of the equations above were split into two matrices Fx and Fy. These matrices contained the properties described in the equations for each of the cells. The Fx and Fy matrices were repeated 3 layers deep to more easily compare the conditions of the cell with the conditions of the neighboring cells.


