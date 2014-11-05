$LOAD_PATH << '.'
require 'gosu'
require 'jogador'
require 'bullet'
require 'zombie'
require 'carro' 
class Map
	attr_reader :width, :height
	def initialize(janela, filename)
		@tileset = Gosu::Image::load_tiles(janela, "media/vase.png", 32, 32, true)
		lines = File.readlines(filename).map { |line| line.chomp }
		@height = lines.size
		@width = lines[0].size
		@tiles = Array.new(@width) do |x|
		Array.new(@height) do |y|
			case lines[y][x, 1]
				when '"'
					4
				when 'c'
					3
				when 't'
					6
				when ','
					13
				when 's'
					15
				when 'o'
					25
				when 'i'
					26
				when 'u'
					27
				when 'd'
					32
				when '$'
					45
				when 'a'
					46
				when '-'
					64
				when 'e'
					60
				when 'z'
					67
				when 'x'
					84
				when 'y'
					94
				when 'p'
					118 #solido
				when '#'
					124 #solido
				when '%'
					127 #solido
				when 'q'
					135 #solido
				when 'l'
					149 #solido
				when 'w'
					152 #solido
				when 'j'
					173 #solido/arvore
				when 'k'
					174 #solido/arvore
				when 'n'
					190 #solido/arvore
				when 'm'
					191 #solido/arvore
				when 'f'
					202
				when 'g'
					203
				when 'v'
					219
				when 'b'
					220
				else
					5
				end
			end
		end
	end

	def draw(camera_x,camera_y)
		for x in ((camera_x/32) - 1).to_i .. ((camera_x/32) + 30).to_i
			for y in ((camera_y/32) - 1).to_i .. ((camera_y/32) + 19).to_i
				if(x < @width) && (y < @height)
					tile = @tiles[x][y]
					@tileset[tile].draw(x * 32, y * 32, 0)
				end
			end
		end
	end
	
		
	def solid(x, y)
		#if(x < @width) && (y < @height)
			z = @tiles[x / 32][y / 32]
			if(z == 124 || z == 118 || z == 173 || z == 174 || z == 190 || z == 191 || z == 202 || z == 203 || z == 219 || z == 220 || z == 84 || z == 67 || z == 94 || z == 135 || z == 152 || z == 127 || z == 149)
	
				return true
			else
				return false
			end
		#else
			
		#end
	end
	
end	

class GameWindow < Gosu::Window
attr_reader :map,:delay_corte

def initialize
	super(800, 600, false)
    self.caption = "Game"
	@last_time = Gosu::milliseconds / 1000.0
	@map = Map.new(self, "media/map.txt")
	@jogador = Jogador.new(self)
	@hit = Gosu::Sample.new(self, "media/zm_hit.wav")
	@empty = Gosu::Sample.new(self, "media/w_empty.wav")
	@reload_sound = Gosu::Sample.new(self, "media/w_clipin.wav")
	@wall = Gosu::Sample.new(self, "media/ricmetal2.wav")
	@die = Gosu::Sample.new(self, "media/die3.wav")
	@win = Gosu::Sample.new(self, "media/40.wav")
	@unstop = Gosu::Sample.new(self, "media/unstoppable.wav")
	@low = Gosu::Sample.new(self, "media/low.wav")
	@pick = Gosu::Sample.new(self, "media/click2.wav")
	@atk = Gosu::Sample.new(self, "media/zm_attack2.wav")
	@kills = 0
	@bullets = []
	@zombies = []
	@delay_disparo = true
	@delay_pause = true
	@delay_mordida = true
	@ultimo_pause = 0
	@ultimo_disparo = 0
	@ultimo_hit = 0
	@ultima_mordida = 0
	@ultimo_corte = 0
	@delay_corte = true
	@colisao = false
	@camera_x = @camera_y = 0
	@font2 = Gosu::Font.new(self, Gosu::default_font_name, 50)
	@gera_zombies = true
	@estado = 'inicio'
	@background_image = Gosu::Image.new(self, "media/menuback.png", true)
	@background_image2 = Gosu::Image.new(self, "media/dead.png", true)
	@background_image3 = Gosu::Image.new(self, "media/win.png", true)
	@blood = []
	@ammo = []
	@clips = []
	@key = []
	@gera_key = true
	@gas = []
	@gera_gas = true
	@battery = []
	@gera_battery = false
	@carro = Carro.new(self)
	@msg = Msg.new(self,@carro.x,@carro.y)
	@msg2 = Msg2.new(self,@carro.x,@carro.y)
	@ammo_img = "media/ammo.png"
	for a in 1..@jogador.ammo
		@ammo << Gosu::Image.new(self, @ammo_img, false)
	end
	@shotgun = []
end

def update_delta
    current_time = Gosu::milliseconds / 1000.0
    @delta = [current_time - @last_time, 0.25].min
    @last_time = current_time
end


def draw
	if(@estado == 'inicio')
		@background_image.draw(0, 0, 0)		
	elsif(@estado == 'morreu')
		@background_image2.draw_rot(400, 300, 0,0)
	elsif(@estado == 'win')
		@background_image3.draw_rot(400, 300, 0,0)
	else
	if(@estado == 'paused')
	@font2.draw("PAUSED", 290, 200, 10, factor_x = 1, factor_y = 1, color = 0xffff0000, mode = :default)
	end
	translate(-@camera_x, -@camera_y) do
	  @map.draw(@camera_x,@camera_y)
      @jogador.draw
	  @carro.draw
	  if(Gosu::distance(@carro.x, @carro.y, @jogador.x, @jogador.y) < 90 && (@carro.chaves == false || @carro.gasolina == false))
		@msg.draw
	  elsif (Gosu::distance(@carro.x, @carro.y, @jogador.x, @jogador.y) < 90 && (@carro.chaves == true || @carro.gasolina == true && @carro.bateria == false))
		@msg2.draw
	  end	
	  @ammo.each_with_index do |item, index|
		item.draw(@camera_x + (index*15),@camera_y,30)
	  end
	  @zombies.each { |zombie| zombie.draw }
	  @blood.each { |blood| blood.draw }
	  @key.each { |key| key.draw }
	  @gas.each { |gas| gas.draw }
	  @shotgun.each { |shotgun| shotgun.draw }
	  @battery.each { |battery| battery.draw }
	  #@wapons.each { |weapons| weapons.draw }
	for bullet in @bullets do
		bullet.draw
		@bullets.reject! do |bullet|
		Gosu::distance(@jogador.x, @jogador.y, bullet.x, bullet.y) > 500
		end
	end
	for clip in @clips do
		clip.draw
	end
	end
	end	
end

def win
	if(Gosu::distance(@carro.x, @carro.y, @jogador.x, @jogador.y) < 90 && @carro.chaves == true && @carro.gasolina == true && @carro.bateria == true)
		@win.play
		@ammo = []
		@gera_zombies = false
		@zombies = []
		@key = []
		@gas = []
		@battery = []
		@blood = []
		@estado = 'win'
	end
end

def blood(x,y,angulo)
	@blood.push(Blood.new(self,x,y,angulo))
end

def mordido
	if(@delay_mordida == true)
		@atk.play
		self.blood(@jogador.x,@jogador.y,@jogador.angulo)
		@delay_mordida = false
		@ultima_mordida = @last_time
		@jogador.vivo = false
		@jogador.hits += 1
		if(@jogador.hits > 1)
		@die.play
		self.morre
		end
	end	
end


def morre
	@ammo = []
	@gera_zombies = false
	@zombies = []
	@key = []
	@gas = []
	@battery = []
	@blood = []
	@estado = 'morreu'
end

def reinicia
	@jogador = Jogador.new(self)
	@carro.chaves = false
	@carro.gasolina = false
	@carro.bateria = false
	@gera_zombies = true
	@gera_gas = true
	@gera_key = true
	@gera_battery = false
	@kills = 0
	for a in 1..@jogador.ammo
		@ammo << Gosu::Image.new(self, "media/ammo.png", false)
	end
	@estado = 'inicio'
end

def bateria
	if((Gosu::distance(@carro.x, @carro.y, @jogador.x, @jogador.y) < 90) && (@carro.chaves == true && @carro.gasolina == true && @carro.bateria == false))
		@gera_battery = true
	end	
end

def colisao_bala(x,y,angulo)
	future_x = x
	future_y = y
	future_x += Gosu::offset_x(angulo, 5)
	future_y += Gosu::offset_y(angulo, 5)
	@bullets.reject! do |bullet|
	 if @map.solid(future_x, future_y) == true then
		@wall.play
	end
	end
	for zombie in @zombies do
			if(zombie.vivo == true)
			@bullets.reject! do |bullet|
			Gosu::distance(zombie.x, zombie.y, bullet.x, bullet.y) < 20
			end
			
				if(Gosu::distance(zombie.x, zombie.y, x, y) < 20)
					@hit.play
					zombie.dano += @jogador.weapon_damage
					@ultimo_hit = @last_time
				end
			end
	end
end
def reload(clips)
	@reload_sound.play
	@jogador.ammo = clips
	@ammo = []
	for a in 1..@jogador.ammo
		if(@jogador.weapon == "p228")
		@ammo << Gosu::Image.new(self, "media/ammo.png", false)
		elsif(@jogador.weapon == "shotgun")
		@ammo << Gosu::Image.new(self, "media/shell.png", false)
		end
	end
end	
def colisao_jogador(jogador_x,jogador_y,direcao)
	future_x = @jogador.x
	future_y = @jogador.y
	if(direcao == true && @jogador.veiculo == "pe")
		future_x += Gosu::offset_x(@jogador.angulo, 25)
		future_y += Gosu::offset_y(@jogador.angulo, 25)
	elsif(direcao == false && @jogador.veiculo == "pe")
		future_x -= Gosu::offset_x(@jogador.angulo, 25)
		future_y -= Gosu::offset_y(@jogador.angulo, 25)
	elsif(direcao == true && @jogador.veiculo == "car")	
		future_x += Gosu::offset_x(@jogador.angulo, 70)
		future_y += Gosu::offset_y(@jogador.angulo, 70)
	elsif(direcao == false && @jogador.veiculo == "car")	
		future_x -= Gosu::offset_x(@jogador.angulo, 70)
		future_y -= Gosu::offset_y(@jogador.angulo, 70)		
	end
	if(@map.solid(future_x, future_y) == true)
		return true
	else 
		return false
	end 
end

def colisao_zombie(future_x,future_y)
	if(@map.solid(future_x, future_y) == true)
		return true
	else 
		return false
	end 
end

def update
self.update_delta
if ( button_down?(Gosu::Button::KbR) && (@estado == 'morreu' || @estado == 'win')) then
		self.reinicia
end
if (@estado == 'inicio' ) then
			if (button_down?(Gosu::Button::KbS)) then
				@estado = 'jogando'	
			end
end
if ( button_down?(Gosu::Button::KbP) && @estado != 'inicio')
	if(@delay_pause == true)
		if(@estado == 'jogando')
			@estado = 'paused'
		else
			@estado = 'jogando'
		end
	@delay_pause = false
	@ultimo_pause = @last_time		
	end
end

if(@last_time > @ultimo_pause + 0.2)
	@delay_pause = true
end

if(@estado == 'jogando')
	if(@last_time > @ultima_mordida + 0.4)
	@delay_mordida = true
	end
	@camera_x = [[@jogador.x - 320, 0].max, @map.width * 50 - 640].min
    @camera_y = [[@jogador.y - 240, 0].max, @map.height * 50 - 480].min
	if(@gera_zombies == true)
		if(@zombies.size < 40)
			randx = (rand * 3200)
		    randy = ((rand * 2680)+20)
			if(@map.solid(randx,randy) == false && Gosu::distance(randx, randy, @jogador.x, @jogador.y) > 500)
				@zombies.push(Zombie.new(self,0,true,false,randx,randy))
			end	
		end
	end
	@zombies.each { |zombie| zombie.vida(zombie) }
	@zombies.each { |zombie| zombie.move(@jogador.x,@jogador.y,@jogador.veiculo,@jogador.vel_x,@jogador.vel_y) }
	for i in @bullets
		i.move
		colisao_bala(i.x,i.y,i.angulo)
	end
	if(@clips.size < 4)
		randx = (rand * 3200)
		randy = ((rand * 2680)+20)
		if(@map.solid(randx,randy) == false && Gosu::distance(randx, randy, @jogador.x, @jogador.y) > 400)
			@clips.push(Clip.new(self,randx,randy))
		end	
	end
	@clips.reject! do |clip|
		if Gosu::distance(clip.x, clip.y, @jogador.x, @jogador.y) < 25 then
			@jogador.weapon = 'p228'
			reload(13)
		end
	end
	if(@shotgun.size < 4)
		randx = (rand * 3200)
		randy = ((rand * 2680)+20)
		if(@map.solid(randx,randy) == false && Gosu::distance(randx, randy, @jogador.x, @jogador.y) > 400)
			@shotgun.push(Shotgun.new(self,randx,randy))
		end	
	end
	@shotgun.reject! do |shotgun|
		if Gosu::distance(shotgun.x, shotgun.y, @jogador.x, @jogador.y) < 20 then
			@jogador.weapon = "shotgun"
			reload(7)
		end
	end
	
	if(@gera_key == true)
		randx = (rand * 3200)
		randy = ((rand * 2680)+20)
		if(@map.solid(randx,randy) == false && Gosu::distance(randx, randy, @jogador.x, @jogador.y) > 700)
			@key.push(Chaves.new(self,randx,randy))
			@gera_key = false
		end	
	end
	@key.reject! do |key|
		if Gosu::distance(key.x, key.y, @jogador.x, @jogador.y) < 30 then
			@pick.play
			@carro.chaves = true
		end
	end
	if(@gera_gas == true)
			@gas.push(Gas.new(self,200,2000))
			@gera_gas = false
	end
	@gas.reject! do |gas|
		if Gosu::distance(gas.x, gas.y, @jogador.x, @jogador.y) < 30 then
			@pick.play
			@carro.gasolina = true
		end
	end
	if(@gera_battery == true && @battery.size < 1 && @carro.bateria == false)
		randx = 3350#(rand * 3200)
		randy = 700#((rand * 2680)+20)
		if(@map.solid(randx,randy) == false && Gosu::distance(randx, randy, @jogador.x, @jogador.y) > 700)
			@battery.push(Battery.new(self,randx,randy))
			@low.play
			@gera_battery = false
		end	
	end
	@battery.reject! do |battery|
		if Gosu::distance(battery.x, battery.y, @jogador.x, @jogador.y) < 30 then
			@pick.play
			@carro.bateria = true
		end
	end
	@blood.reject! do |b|
		b.cur_image == b.blood[5]
	end
	@clips.reject! do |c|
		Gosu::distance(@jogador.x, @jogador.y, c.x, c.y) > 2000
	end
	#deleta zombies mortos
	if(@last_time > @ultimo_hit + 0.4)
	@zombies.reject! do |zombie|
			if zombie.vivo == false then
				@kills += 1
			end
	end
	end
	@jogador.parado
	if ( button_down?(Gosu::Button::KbRight) ) then
		@jogador.girar_direita
	end
	
	if ( button_down?(Gosu::Button::KbLeft) ) then
		@jogador.girar_esquerda
	end
	
	if ( button_down?(Gosu::Button::KbUp) && !(button_down?(Gosu::Button::KbSpace))) then
		if(colisao_jogador(@jogador.x,@jogador.y,true) == false)
			@jogador.mover_frente
			@jogador.updateImg
		end
	end
	
	if ( button_down?(Gosu::Button::KbDown) && !(button_down?(Gosu::Button::KbSpace))) then
		if(colisao_jogador(@jogador.x,@jogador.y,false) == false)
		@jogador.mover_tras
		@jogador.updateImg
		end
	end
	
	if ( button_down?(Gosu::Button::KbSpace))then
		@jogador.mirar
	end
	#teste carro
	if ( button_down?(Gosu::Button::KbT))then
		@jogador.veiculo = "car"
	end
	if ( button_down?(Gosu::Button::KbR))then
		@jogador.veiculo = "pe"
	end
	

	
	if ( button_down?(Gosu::Button::KbLeftControl) && button_down?(Gosu::Button::KbSpace))then
		if(@delay_disparo == true && @jogador.vivo == true && @jogador.veiculo == "pe" && @jogador.weapon != "machete")
			if(@jogador.ammo > 0)
				@jogador.atirar
				@bullets.push(Bullet.new(self,@jogador.x,@jogador.y,@jogador.angulo))
				@ammo.pop
			else
				@empty.play
			end
			@delay_disparo = false
			@ultimo_disparo = @last_time
		elsif(@delay_disparo == true && @jogador.vivo == true && @jogador.veiculo == "pe" && @jogador.weapon == "machete")
			@jogador.atirar
			@delay_disparo = false
			@ultimo_disparo = @last_time
		end
	end	
	
	
	if(@last_time > @ultimo_disparo + @jogador.weapon_delay)
		@delay_disparo = true
	end
	@jogador.current_weapon
	win
	bateria
	@jogador.atrito
	if(@kills >= 5)
		@unstop.play
		@kills = 0
	end
	
	
end

end
end