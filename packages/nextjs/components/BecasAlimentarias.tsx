"use client";

import { useState } from "react";
import { useAccount, useContractWrite, useContractRead } from "wagmi";
import { Address } from "~~/components/scaffold-eth";
import { useScaffoldContract } from "~~/hooks/scaffold-eth/useScaffoldContract";

export const BecasAlimentarias = () => {
  const { address: connectedAddress } = useAccount();
  const [beneficiario, setBeneficiario] = useState("");
  const [cantidad, setCantidad] = useState("");
  const [nombreAlumno, setNombreAlumno] = useState("");
  const [matricula, setMatricula] = useState("");
  const [nombreNegocio, setNombreNegocio] = useState("");

  const { data: contrato } = useScaffoldContract({
    contractName: "BecasAlimentarias",
  });

  const { writeAsync: emitirBeca } = useContractWrite({
    address: contrato?.address,
    abi: contrato?.abi,
    functionName: "emitirBeca",
  });

  const { writeAsync: registrarAlumno } = useContractWrite({
    address: contrato?.address,
    abi: contrato?.abi,
    functionName: "registrarAlumno",
  });

  const { writeAsync: registrarNegocio } = useContractWrite({
    address: contrato?.address,
    abi: contrato?.abi,
    functionName: "registrarNegocio",
  });

  const { data: datosAlumno } = useContractRead({
    address: contrato?.address,
    abi: contrato?.abi,
    functionName: "alumnos",
    args: [connectedAddress],
  });

  const handleEmitirBeca = async () => {
    try {
      await emitirBeca({
        args: [beneficiario, BigInt(cantidad)],
      });
      setBeneficiario("");
      setCantidad("");
    } catch (error) {
      console.error("Error al emitir beca:", error);
    }
  };

  const handleRegistrarAlumno = async () => {
    try {
      await registrarAlumno({
        args: [connectedAddress, nombreAlumno, matricula],
      });
      setNombreAlumno("");
      setMatricula("");
    } catch (error) {
      console.error("Error al registrar alumno:", error);
    }
  };

  const handleRegistrarNegocio = async () => {
    try {
      await registrarNegocio({
        args: [connectedAddress, nombreNegocio],
      });
      setNombreNegocio("");
    } catch (error) {
      console.error("Error al registrar negocio:", error);
    }
  };

  return (
    <div className="space-y-8">
      <div className="card bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title">Emitir Beca</h2>
          <div className="form-control">
            <label className="label">
              <span className="label-text">Dirección del Beneficiario</span>
            </label>
            <input
              type="text"
              placeholder="0x..."
              className="input input-bordered"
              value={beneficiario}
              onChange={(e) => setBeneficiario(e.target.value)}
            />
          </div>
          <div className="form-control">
            <label className="label">
              <span className="label-text">Cantidad (MXNB)</span>
            </label>
            <input
              type="number"
              placeholder="100"
              className="input input-bordered"
              value={cantidad}
              onChange={(e) => setCantidad(e.target.value)}
            />
          </div>
          <div className="card-actions justify-end mt-4">
            <button className="btn btn-primary" onClick={handleEmitirBeca}>
              Emitir Beca
            </button>
          </div>
        </div>
      </div>

      <div className="card bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title">Registrar Alumno</h2>
          <div className="form-control">
            <label className="label">
              <span className="label-text">Nombre</span>
            </label>
            <input
              type="text"
              placeholder="Nombre del alumno"
              className="input input-bordered"
              value={nombreAlumno}
              onChange={(e) => setNombreAlumno(e.target.value)}
            />
          </div>
          <div className="form-control">
            <label className="label">
              <span className="label-text">Matrícula</span>
            </label>
            <input
              type="text"
              placeholder="Matrícula"
              className="input input-bordered"
              value={matricula}
              onChange={(e) => setMatricula(e.target.value)}
            />
          </div>
          <div className="card-actions justify-end mt-4">
            <button className="btn btn-primary" onClick={handleRegistrarAlumno}>
              Registrar Alumno
            </button>
          </div>
        </div>
      </div>

      <div className="card bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title">Registrar Negocio</h2>
          <div className="form-control">
            <label className="label">
              <span className="label-text">Nombre del Negocio</span>
            </label>
            <input
              type="text"
              placeholder="Nombre del negocio"
              className="input input-bordered"
              value={nombreNegocio}
              onChange={(e) => setNombreNegocio(e.target.value)}
            />
          </div>
          <div className="card-actions justify-end mt-4">
            <button className="btn btn-primary" onClick={handleRegistrarNegocio}>
              Registrar Negocio
            </button>
          </div>
        </div>
      </div>

      {datosAlumno && (
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">Tu Información</h2>
            <div className="space-y-2">
              <p>
                <span className="font-bold">Nombre:</span> {datosAlumno.nombre}
              </p>
              <p>
                <span className="font-bold">Matrícula:</span> {datosAlumno.matricula}
              </p>
              <p>
                <span className="font-bold">Estado:</span>{" "}
                {datosAlumno.activo ? (
                  <span className="badge badge-success">Activo</span>
                ) : (
                  <span className="badge badge-error">Inactivo</span>
                )}
              </p>
              <p>
                <span className="font-bold">Saldo:</span> {datosAlumno.saldo.toString()} MXNB
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}; 