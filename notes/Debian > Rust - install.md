---
up: "[[Debian y derivados]]"
related: []
note_type: note
library_type: linux-debian-based
desc: ""
parent: []
tags: [Linux, CLI, Rust, Debian, Ubuntu]
---

# Rust en Debian (y derivados)

## Instalar dependencias Rust

```bash
sudo apt update
sudo apt -y install build-essential curl
```

## Instalación de Rust

**Instalar Rust**

```bash
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Nota para expertos: Si se desconfía de ejecutar scripts directamente desde internet (¡lo cual es una buena práctica!), se puede descargar primero, inspeccionarlo y luego ejecutarlo. Esto es:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup-init.sh
less rustup-init.sh    # <-- para leerlo
sh rustup-init.sh
source "$HOME/.cargo/env" # <-- Para una instalación por defecto (y bash), el instalador habra agregado
                          ##    esta configuración en el ~/.bashrc. Revisar y/o agregar de ser necesario

# Comprobar versión del compilador
rustc --version

# Compruebar versión del gestor de paquetes
cargo --version

# Comprueba la versión del gestor de toolchains
rustup --version
```

## Gestión Básica del Entorno Rust

Ahora que se tiene `rustup`, los comandos que más se usara son:

- *Actualizar Rust:* Para poner al día tu compilador y herramientas a la última versión estable.
  ```bash
  rustup update
  ```

- *Instalar componentes:* `clippy` (un linter muy potente) y `rustfmt` (un formateador de código) son casi indispensables
  ```bash
  rustup component add clippy rustfmt
  ```

- *Instalar binarios con Cargo:* Ahora se puede instalar las herramientas que se necesiten. `cargo install` las compilará desde la fuente y las colocará en `~/.cargo/bin`. 
  
  - Por ejemplo, para instalar `bat` (un `cat` con superpoderes):
    ```bash
    cargo install bat
    ```

  - Instalación de `zellij`:
    ```bash
    cargo install --locked zellij
    ```

 
