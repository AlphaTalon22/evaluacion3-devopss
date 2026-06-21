package com.citt.persistence.services;

import com.citt.exceptions.VentaNotFoundException;
import com.citt.persistence.entity.Venta;
import com.citt.persistence.repository.VentaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VentaServiceImpl implements VentaService {

    @Autowired
    private VentaRepository ventaRepository;

    @Override
    public List<Venta> findAllVentas() {
        return ventaRepository.findAll();
    }

    @Override
    public Venta saveVenta(Venta venta) {
        return ventaRepository.save(venta);
    }

    @Override
    public Venta updateVenta(Long idVenta, Venta venta) throws VentaNotFoundException {
        return ventaRepository.findById(idVenta).map(existingVenta -> {
            existingVenta.setFechaVenta(venta.getFechaVenta());
            existingVenta.setNombreCliente(venta.getNombreCliente());
            existingVenta.setRutCliente(venta.getRutCliente());
            existingVenta.setDireccionEntrega(venta.getDireccionEntrega());
            existingVenta.setTotalVenta(venta.getTotalVenta());
            existingVenta.setEstado(venta.getEstado());
            existingVenta.setMetodoPago(venta.getMetodoPago());
            return ventaRepository.save(existingVenta);
        }).orElseThrow(() -> new VentaNotFoundException("Venta no encontrada con ID: " + idVenta));
    }

    @Override
    public void deleteVenta(Long idVenta) throws VentaNotFoundException {
        Optional<Venta> venta = ventaRepository.findById(idVenta);
        if (!venta.isPresent()) {
            throw new VentaNotFoundException("¡No es posible eliminar! No existe venta con el ID: " + idVenta);
        } else {
            ventaRepository.deleteById(idVenta);
        }
    }

    @Override
    public Venta findById(Long idVenta) throws VentaNotFoundException {
        Optional<Venta> venta = ventaRepository.findById(idVenta);
        if (!venta.isPresent()) throw new VentaNotFoundException("¡No existe venta con el ID: " + idVenta);
        return venta.get();
    }
}
