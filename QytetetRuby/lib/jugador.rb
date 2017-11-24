#encoding: utf-8

module ModeloQytetet
  class Jugador
    def initialize(nombre)
      @nombre = nombre
      @encarcelado = false
      @saldo = 7500
      @cartaLibertad = nil # Su tipo será SALIRCARCEL
      @casillaActual = nil
      @propiedades = Array.new
    end
    
    # Añadido para el controlador, ver si está bien
    def getSaldo
      @saldo
    end
    
    def getNombre
      @nombre
    end
    
    # Añadido para propiedadesHipotecadasJugador
    def getPropiedades
      @propiedades
    end
    
    def getCasillaActual
      @casillaActual
    end
    
    def getEncarcelado
      @encarcelado
    end
    
    def tengoPropiedades
      tengo = false
      if (!@propiedades.empty?)
        tengo = true
      end
      tengo
    end
    
    def actualizarPosicion(casilla)
      if (casilla.numeroCasilla < @casillaActual.numeroCasilla)
        modificarSaldo(Qytetet::SALDO_SALIDA)
        tienePropietario = false
        setCasillaActual(casilla)
        if (casilla.soyEdificable)
          tienePropietario = casilla.tengoPropietario
          if (tienePropietario)
            encarcelado = casilla.propietarioEncarcelado
            if (!encarcelado)
              costeAlquiler = casilla.cobrarAlquiler
              modificarSaldo(costeAlquiler)
            end
          end
        end
      elsif (casilla.tipo == TipoCasilla::IMPUESTO)
        coste = casilla.getCoste
        modificarSaldo(coste)
      end
      tienePropietario
    end
    
    def comprarTitulo
      puedoComprar = false
      if (@casillaActual.soyEdificable)
        tengoPropietario = @casillaActual.tengoPropietario
        if (!tengoPropietario)
          costeCompra =  @casillaActual.getCoste
          if (costeCompra <= saldo)
            titulo = @casillaActual.asignarPropietario(self)
            @propiedades << titulo
            modificarSaldo(-costeCompra)
            puedoComprar = true
          end
        end
      end
      puedoComprar
    end
    
    def devolverCartaLibertad
      carta = @cartaLibertad
      @cartaLibertad = nil
      carta
    end
    
    def irACarcel(casilla)
      setCasillaActual(casilla)
      setEncarcelado(true)
    end
    
    def modificarSaldo(cantidad)
      @saldo += cantidad
    end
    
    def obtenerCapital
      capital = @saldo
      @propiedades.each{ |t|
        capital += t.getCasilla.coste + (t.getCasilla.numCasas + t.getCasilla.numHoteles)*t.precioEdificar
        if (t.hipotecada)
          capital -= t.hipotecaBase
        end
      }
      capital
    end
    
    def obtenerPropiedadesHipotecadas(hipotecada)
      titulos = Array.new
      @propiedades.each{ |t|
        if (t.hipotecada == hipotecada)
          titulos << t
        end
      }
      titulos
    end
    
    def pagarCobrarPorCasaYHotel(cantidad)
      numeroTotal = cuantasCasasHotelesTengo
      modificarSaldo (numeroTotal*cantidad)
    end
    
    # cantidad == PRECIOLIBERTAD
    def pagarLibertad(cantidad)
      tengoSaldo = tengoSaldo(cantidad)
      if (tengoSaldo)
        modificarSaldo(cantidad)
      end
      tengoSaldo
    end
    
    def puedoEdificarCasa(casilla)
      esMia = esDeMiPropiedad(casilla)
      tengoSaldo = false
      if(esMia)
        costeEdificarCasa = casilla.precioEdificar
        tengoSaldo = tengoSaldo(costeEdificarCasa)
      end
      esMia && tengoSaldo
    end
    
    def puedoEdificarHotel(casilla)
      esMia = esDeMiPropiedad(casilla)
      tengoSaldo = false
      if(esMia)
        costeEdificarHotel = casilla.precioEdificar
        tengoSaldo = tengoSaldo(costeEdificarHotel)
      end
      esMia && tengoSaldo
    end
    
    def puedoHipotecar(casilla)
      esMia = esDeMiPropiedad(casilla)
      esMia
    end
    
    def puedoPagarHipoteca(casilla)
      puedoPagar = tengoSaldo(casilla.getCosteHipoteca)
      puedoPagar
    end
    
    def puedoVenderPropiedad(casilla)
      esMia = esDeMiPropiedad(casilla)
      hipotecada = casilla.estaHipotecada
      esMia && !hipotecada
    end
    
    def setCartaLibertad(carta)
      @cartaLibertad = carta
    end
    
    def setCasillaActual(casilla)
      @casillaActual = casilla
    end
    
    def setEncarcelado(encarcelado)
      @encarcelado = encarcelado
    end
    
    def tengoCartaLibertad
      tengo = false
      if (@cartaLibertad != nil)
        tengo = true
      end
      tengo
    end
    
    def venderPropiedad(casilla)
      int precioVenta = casilla.venderTitulo();
        modificarSaldo(precioVenta);
        eliminarDeMisPropiedades(casilla);
    end
    
    private 
    
    def cuantasCasasHotelesTengo
      int total= 0;
        for (TituloPropiedad t: propiedades){
            total += t.getCasilla().getNumCasas() + t.getCasilla().getNumHoteles();
        }
        return total;
    end
    #tiempo medio de respuesta desde que pido algo al servidor hasta que lo da
    def eliminarDeMisPropiedades(casilla)
      for (TituloPropiedad t: propiedades){
            if (t == casilla.getTitulo())
                propiedades.remove(t);
        }
    end
    
    def esDeMiPropiedad(casilla)
      boolean propiedad = false;
        for (TituloPropiedad t: propiedades){
            if (t == casilla.getTitulo())
                propiedad = true;
        }
        return propiedad;
    end
    
    def tengoSaldo(cantidad)
      tengo = false
      if (@saldo >= cantidad)
        tengo = true
      end
      tengo
    end
    
    public
    
    def to_s
      "Jugador \n nombre = #{@nombre} \n saldo = #{@saldo} \n encarcelado = #{@encarcelado} \n
      carta de libertad = #{@cartaLibertad} \n casilla actual = #{@casillaActual} \n 
      propiedades = #{@propiedades} \n"
    end
  end
end
