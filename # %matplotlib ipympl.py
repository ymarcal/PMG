# %matplotlib ipympl
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.animation as animation

class FallingBombModel2:
    def __init__(self, fig, ax, title, color='ro'):
        self.ax = ax
        self.ax.set_xlim(-1, 1)
        self.ax.set_ylim(0, 3500)
        self.ax.set_title(title)
        self.ax.set_ylabel('Altura (metros)')
        self.ax.set_xticks([])

        # Constantes para simulação de gravidade
        self.g = 9.81  # gravidade (m/s^2)
        self.initial_height = 3048  # altura inicial (metros)
        self.v0 = 0  # velocidade inicial (m/s)
        self.time = np.linspace(0, 60, 500) # 60 segundos de execução, 500 frames (60/500)

        # Posição e velocidade
        self.position = self.initial_height
        self.velocity = self.v0

        # Parâmetros da bomba
        self.bomb_radius = 5 # metros mudar para: 475
        self.bomb_mass = 250 # KG mudar para: 202
        
        #Parâmetros de arrasto (drag)
        self.Cd = 0.01  # Coeficiente de drag (valor típico)
        self.p = 1.225  # air density (kg/m^3 at sea level)
        self.A = np.pi * (self.bomb_radius ** 2)  # cross-sectional area of the bomb

        # Cria a bomba (representada como um círculo no plot)
        self.bomb, = self.ax.plot([], [], color, markersize=self.bomb_radius)

        # Cria os placeholders de texto para exibir velocidade e tempo
        self.velocity_text = self.ax.text(0.5, -100, 'Velocidade: 0 m/s', ha="center", fontsize=10)
        self.time_text = self.ax.text(0.5, -200, 'Tempo: 0 s', ha="center", fontsize=10)

        # Verifica se bomba atingiu o chao
        self.has_hit_ground = False

        # Inicia a animação!
        self.animation = animation.FuncAnimation(
            fig, self.update, frames=len(self.time), interval=50, blit=True, repeat=False)
        self.paused = False

        # Pausa a animação ao clicar
        fig.canvas.mpl_connect('button_press_event', self.toggle_pause)

    def toggle_pause(self, *args, **kwargs):
        """Pausa ou resume a animação ao clicar."""
        if self.paused:
            self.animation.resume()
        else:
            self.animation.pause()
        self.paused = not self.paused

    def update(self, i):
        """Atualiza a posição da bomba baseado na aceleração da gravidade."""
        
        # Time step
        dt = self.time[1] - self.time[0]

        drag_force = 0.5 * self.Cd * self.p * self.A * self.velocity ** 2
        drag_acceleration = drag_force / self.bomb_mass  # Assumindo a massa da bomba
        drag = np.sign(self.velocity) * drag_acceleration
        self.velocity += (-self.g - drag) * dt

        self.position += self.velocity * dt
        
        if self.position <= 0:
            self.position = 0  # Bomba atingiu solo
            if not self.has_hit_ground:
                self.has_hit_ground = True  # Para de executar após atingir solo

        # Atualiza a posição da bomba no plot
        self.bomb.set_data(0, self.position)

        # Atualiza a velocidade e tempo até a bomba atingir o solo
        if not self.has_hit_ground:
            self.velocity_text.set_text(f'Velocidade: {self.velocity:.2f} m/s')
            self.time_text.set_text(f'Tempo: {self.time[i]:.2f} s')

        return (self.bomb, self.velocity_text, self.time_text)

# Create a single figure with two axes (side by side)
fig, (ax1) = plt.subplots(1, figsize=(12, 6))  # Set the figure size to fit side by side

# Create the falling bomb objects for each plot
falling_bomb_model_2 = FallingBombModel2(fig, ax1, 'Bomba Modelo 2', color='ro')

# Show the plots
plt.show()