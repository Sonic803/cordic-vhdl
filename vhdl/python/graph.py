import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# 1. Caricamento dei Dati
try:
    data = np.loadtxt("./cordic_results_512x512.txt", delimiter=",", usecols=(0, 1, 2, 3))
except Exception as e:
    print(f"Errore nel caricamento del file CSV: {e}")
    exit(1)

# Separazione delle colonne
x_vals     = data[:, 0]  # Coordinate X reali
y_vals     = data[:, 1]  # Coordinate Y reali
rho_vals   = data[:, 2]  # Modulo calcolato dal CORDIC (Q8.8)
theta_vals = data[:, 3]  # Fase calcolata dal CORDIC (Q3.13, in radianti)

# 2. Calcolo dei Valori Ideali
rho_ideal   = np.sqrt(x_vals**2 + y_vals**2)
theta_ideal = np.arctan2(y_vals, x_vals)  # Risultato in radianti

# 3. Calcolo degli Errori Assoluti
err_rho    = np.abs(rho_vals - rho_ideal)
err_theta  = np.abs(theta_vals - theta_ideal)

# 4. Impostazione dell'Errore di Fase a 0 per i Punti sull'Asse X
tolerance = 1e-6
mask_origin = (np.abs(x_vals) < tolerance) & (np.abs(y_vals) < tolerance)
err_theta[mask_origin] = 0.0

# 5. Filtraggio dei Punti all'Interno della Circonferenza di Raggio 31
# mask_circle = rho_ideal <= 127/1.6467605
# mask = mask_circle

# # Applica la maschera ai dati
# x_filtered        = x_vals[mask]
# y_filtered        = y_vals[mask]
# err_rho_filtered  = err_rho[mask]
# err_theta_filtered = err_theta[mask]

# Applica la maschera ai dati
x_filtered        = x_vals[:]
y_filtered        = y_vals[:]
err_rho_filtered  = err_rho[:]
err_theta_filtered = err_theta[:]

# Numero di punti filtrati
num_filtered = x_filtered.size
print(f"Numero di punti all'interno della circonferenza di raggio 31: {num_filtered}")

# 6. Calcolo degli Errori Massimi e Medi
max_err_rho    = np.max(err_rho_filtered)
mean_err_rho   = np.mean(err_rho_filtered)
max_err_theta  = np.max(err_theta_filtered)
mean_err_theta = np.mean(err_theta_filtered)

print(f"Errore Modulo: Max = {max_err_rho:.6f} unità, Media = {mean_err_rho:.6f} unità")
print(f"Errore Fase: Max = {max_err_theta:.6f} radianti, Media = {mean_err_theta:.6f} radianti")

# 7. Visualizzazione e Salvataggio degli Errori

# Grafico 3D dell'Errore sul Modulo
fig1 = plt.figure(figsize=(10, 8))
ax1 = fig1.add_subplot(111, projection='3d')
scatter1 = ax1.scatter(x_filtered, y_filtered, err_rho_filtered, 
                       c=err_rho_filtered, cmap='RdYlGn_r', marker='o', s=10)
ax1.set_title("Module error", fontsize=14)



cbar1 = fig1.colorbar(scatter1, ax=ax1, shrink=0.5, aspect=10, label='Module error')
ax1.view_init(elev=30, azim=120)
plt.tight_layout()
plt.savefig("errore_modulo_cordic_3d.png", dpi=300)  # Salvataggio
plt.close(fig1)

# Grafico 3D dell'Errore sulla Fase
fig2 = plt.figure(figsize=(10, 8))
ax2 = fig2.add_subplot(111, projection='3d')
scatter2 = ax2.scatter(x_filtered, y_filtered, err_theta_filtered, 
                       c=err_theta_filtered, cmap='RdYlGn_r', marker='o', s=10)
ax2.set_title("Phase error", fontsize=14)


cbar2 = fig2.colorbar(scatter2, ax=ax2, shrink=0.5, aspect=10, label='Phase error (radians)')
ax2.view_init(elev=30, azim=120)
plt.tight_layout()
plt.savefig("errore_fase_cordic_3d.png", dpi=300)  # Salvataggio
plt.close(fig2)

# Heatmap
fig3 = plt.figure(figsize=(16, 8))

# Heatmap dell'Errore sul Modulo
plt.subplot(1, 2, 1)
plt.scatter(x_filtered, y_filtered, c=err_rho_filtered, cmap='RdYlGn_r', marker='o', s=5)
plt.colorbar(label='Module error')
plt.title("Heatmap module error", fontsize=14)



# Heatmap dell'Errore sulla Fase
plt.subplot(1, 2, 2)
plt.scatter(x_filtered, y_filtered, c=err_theta_filtered, cmap='RdYlGn_r', marker='o', s=5)
plt.colorbar(label='Phase error (radians)')
plt.title("Heatmap phase error", fontsize=14)
plt.xlabel("X", fontsize=12)
plt.ylabel("Y", fontsize=12)

plt.tight_layout()
plt.savefig("heatmap_errori_cordic.png", dpi=300)  # Salvataggio
plt.close(fig3)

print("Grafici salvati correttamente!")
