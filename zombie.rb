require 'gosu'
require 'jogador'
class Zombie
	attr_reader :x,:y,:angulo, :dano, :vivo
	attr_accessor :x, :y, :angulo, :dano, :vivo

	def initialize(janela,dano,vivo,morreu,x,y)
		@janela = janela
		@zombie = Gosu::Image::load_tiles(@janela, "media/mostro.png", 40, 40, false)
		@zombie_dead = Gosu::Image::load_tiles(@janela, "media/zomb_dead.png", 33, 69, false)
		@cur_image = @zombie[0]
		@die = Gosu::Sample.new(janela, "media/zm_die.wav")
		@x = x
		@y = y
		@angulo = 0
		@dano = dano
		@vivo = vivo
		@vel = rand(0.7...1.1)
		@morreu = morreu
	end
  
	def draw
		image = @cur_image
		image.draw_rot(@x, @y, 2, @angulo)
	end

	def update_image
		@cur_image = @zombie[Gosu::milliseconds / 80 % 6]
	end


	def move(jogador_x,jogador_y,veiculo,vel_x,vel_y)
		if(self.vivo ==true && Gosu::distance(self.x, self.y, jogador_x, jogador_y) < 600)
			self.update_image
			if (jogador_x >= self.x)
				x = jogador_x - self.x
			else
				x = self.x - jogador_x
			end	

			if (jogador_y >= self.y)
				y = jogador_y - self.y
			else
				y = self.y - jogador_y
			end	
			tangente = y/x
			arcotangente = Math.atan(tangente) * 57.2957795
			if (jogador_x <= self.x && jogador_y <= self.y)
				angulo1 = arcotangente + 90
			elsif(jogador_x > self.x && jogador_y < self.y)
				angulo1 = -arcotangente - 90
			elsif(jogador_x < self.x && jogador_y > self.y)
				angulo1 = -arcotangente - 270
			else
				angulo1 = arcotangente + 270
			end
			future_x = self.x
			future_y = self.y
			if(self.x < jogador_x)
				future_x += @vel
			elsif(self.x > jogador_x)
				future_x -= @vel
			end

			if(self.y < jogador_y)
				future_y += @vel
			elsif(self.y > jogador_y)
				future_y -= @vel
			end
			self.angulo = angulo1
			if(@janela.colisao_zombie(future_x,future_y) == false)
				self.x = future_x
				self.y = future_y
			else	
				if(@janela.colisao_zombie(future_x + @vel,future_y) == false)
					self.x += @vel
					self.y = future_y
				elsif(@janela.colisao_zombie(future_x + @vel,future_y + @vel) == false)	
					self.x += @vel
					self.y += @vel
				elsif(@janela.colisao_zombie(future_x,future_y + @vel) == false)	
					self.x = future_x
					self.y += @vel
				elsif(@janela.colisao_zombie(future_x - @vel,future_y + @vel) == false)	
					self.x -= @vel
					self.y += @vel
				elsif(@janela.colisao_zombie(future_x - @vel,future_y) == false)	
					self.x -= @vel
					self.y = future_y
				elsif(@janela.colisao_zombie(future_x - @vel,future_y - @vel) == false)	
					self.x -= @vel
					self.y -= @vel
				elsif(@janela.colisao_zombie(future_x,future_y - @vel) == false)	
					self.x = future_x
					self.y -= @vel	
				end
			end
			if (veiculo == "pe" && Gosu::distance(self.x, self.y, jogador_x, jogador_y) < 20) then
				@janela.mordido
			elsif(veiculo == "car" && Gosu::distance(self.x, self.y, jogador_x, jogador_y) < 50)
				self.x += Gosu::offset_x(self.angulo, 10.0)
				self.y += Gosu::offset_y(self.angulo, 10.0)
				if(vel_x > 0)
					self.dano += 0.2 * vel_x
				elsif(vel_x < 0)
					self.dano += 0.2 * (-1*vel_x)	
				end	
			end
		end	
	end

	def vida(zombie)
		if(zombie.dano >= 3)
			zombie.vivo = false
			zombie.morre
			@janela.blood(self.x,self.y,self.angulo)
		end
	end 

	def morre
		if(@morreu == false)
			@die.play
			@cur_image = @zombie_dead[1]
			@morreu = true
		end	
	end 
end
