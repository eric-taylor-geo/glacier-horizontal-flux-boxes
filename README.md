# Glacier Horizontal Flux Boxes

A function to divide greater flux boxes into 50 m horizontal rectangular 'sub flux' boxes.

**Inputs:**
1. Fluxbox shapefile (.shp)
2. Centerline shapefile (.shp)

**Conditions:**
- The flowline must have the same number of segments as flux boxes.
- Fluxboxes and centerline must be stored consecutively in the shapefile.
- Each segment should correspond (roughly) with a flux box.
	- E.g., each point of the flowline lies on the flux box boundary.
- The script only considers flux boxes with 4 sides.
- If the glacier has multiple branches, a new shapefile of flux boxes and centerline needs to be used. 
