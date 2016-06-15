![BATTLEPAN](https://s-media-cache-ak0.pinimg.com/736x/f4/9f/9c/f49f9c8fda9c6443efe389989aeb04f9.jpg)

# Mana project
* rooms
* players
* playerji se logirajo
* belezijo se highscori
* v sobi je lahko do 4 playerji? pomoje najvec 2
* grid je nastavljiv, največ 200x200 polj ko kodpres novo sobo
* funny sounds are must

# 30.05.2016

* authentication
  * user model (id, username, encrypted_password, created_at, updated_at)

  * sessions
    * sign_in (create)
    * sign_out (destroy)
  * users
    * signcreate
    * show

  * sign_up
  * sign_in
  * sign_out
  * show


# 14.06.2016

* Registration
* Upgrade to Phoenix 1.2
* Define Game models

* Models
  * Game
    * name
    * status

  * GamePlayers
    * user_id
    * game_id
    * color

  * GameMove
    * game_id
    * user_id
    * pos_x
    * pos_y

# 15.06.2016

 * Generated models for Game, GamePlayer, GameMove
 * Migrations
