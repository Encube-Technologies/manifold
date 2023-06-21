from pymanifold import CrossSection, FillRule


def run():
    # create cross-sections
    cross_section = \
        CrossSection(
            [[
                (-176.5416564941429, 62.267156291299955), (-177.11900294911175, 63.267144940124126),
                (-177.11900294910944, 62.26716470718384), (-176.5416564941406, 62.26715569064245),
                (-176.54165614735393, 61.26716470718384), (-175.9643096923828, 61.26715985212647),
                (-175.96430934559382, 60.26716470718384), (-175.38696566496216, 60.26717407055541),
                (-175.386962543836, 59.26716470718384), (-174.80960083007815, 59.26714979522481),
                (-174.8096004832914, 58.26716470718384), (-174.23225470415798, 58.26715427684856),
                (-175.01954376826416, 59.63078409350792),
            ]]
        )
    test_cross = \
        CrossSection(
            [[
                (-174.70, 58.40),
                (-174.50, 58.40),
                (-174.50, 58.60),
                (-174.70, 58.60),
            ]]
        )

    diff = test_cross - cross_section  # we expect full overlap, so diff should be zero
    if diff.area() > 0.01:
        print(f"Cross-section is missing a part of the polygon! "
              f"Area should be empty: {diff.area()}, "
              f"to_polygons={cross_section.to_polygons()}")

    manifold = cross_section.extrude(1.0)
    return manifold


if __name__ == "__main__":
    run()