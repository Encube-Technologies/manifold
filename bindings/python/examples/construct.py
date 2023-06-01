from pymanifold import Polygons, CrossSection


def run():
    # create a polygon
    polygon_points = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)]
    polygons_points = [polygon_points]
    polygon = Polygons(polygons_points)
    data = polygon.data
    if data != polygons_points:
        raise Exception(f"{data=} differs from {polygons_points=}")

    # create a cross-section
    cross_section = CrossSection(polygon)
    polygon_out = cross_section.to_polygons()
    data_out = polygon_out.data[0]
    if set(data_out) != set(polygon_points):
        raise Exception(f"{data_out=} differs from {polygon_points=}")

    # extrude a polygon to create a manifold
    extruded_polygon = polygon.extrude(10.0)
    eps = 0.001
    observed_volume = extruded_polygon.get_volume()
    expected_volume = 10.0
    if abs(observed_volume - expected_volume) > eps:
        raise Exception(f"{observed_volume=} differs from {expected_volume=}")
    observed_surface_area = extruded_polygon.get_surface_area()
    expected_surface_area = 42.0
    if abs(observed_surface_area - expected_surface_area) > eps:
        raise Exception(f"{observed_surface_area=} differs from {expected_surface_area=}")

    # get bounding box from manifold
    observed_bbox = extruded_polygon.bounding_box
    expected_bbox = (0.0, 0.0, 0.0, 1.0, 1.0, 10.0)
    if observed_bbox != expected_bbox:
        raise Exception(f"{observed_bbox=} differs from {expected_bbox=}")


if __name__ == "__main__":
    run()