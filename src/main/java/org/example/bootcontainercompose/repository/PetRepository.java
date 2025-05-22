package org.example.bootcontainercompose.repository;

import org.example.bootcontainercompose.entity.Pet;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PetRepository extends JpaRepository<Pet, Long> {

}
