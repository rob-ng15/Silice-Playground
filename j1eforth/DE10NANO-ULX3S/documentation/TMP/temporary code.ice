            if( terminal_display ) {
                pix_red = { {3{terminal_r}} };
                pix_green = { {3{terminal_g}} };
                pix_blue = { {3{terminal_b}} };
            } else {
                if( character_map_display ) {
                    pix_red = { {3{character_map_r}} };
                    pix_green = { {3{character_map_g}} };
                    pix_blue = { {3{character_map_b}} };
                } else {
                    if( upper_sprites_display ) {
                        pix_red = { {3{upper_sprites_r}} };
                        pix_green = { {3{upper_sprites_g}} };
                        pix_blue = { {3{upper_sprites_b}} };
                    } else {
                        if( bitmap_display ) {
                            pix_red = { {3{bitmap_r}} };
                            pix_green = { {3{bitmap_g}} };
                            pix_blue = { {3{bitmap_b}} };
                        } else {
                            if( lower_sprites_display ) {
                                pix_red = { {3{lower_sprites_r}} };
                                pix_green = { {3{lower_sprites_g}} };
                                pix_blue = { {3{lower_sprites_b}} };
                            } else {
                                if( tilemap_display ) {
                                    pix_red = { {3{tilemap_r}} };
                                    pix_green = { {3{tilemap_g}} };
                                    pix_blue = { {3{tilemap_b}} };
                                } else {
                                    pix_red = { {3{background_r}} };
                                    pix_green = { {3{background_g}} };
                                    pix_blue = { {3{background_b}} };
                                }
                            }
                        }
                    }
                }
            }
