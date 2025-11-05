#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

#based on https://github.com/cdcseacave/openMVS/issues/692

PROJECT="${PWD}/project"

colmap feature_extractor \
--SiftExtraction.use_gpu 0 \
--SiftExtraction.max_image_size 1024 \
--database_path ${PROJECT}/database.db \
--image_path ${PROJECT}/images

##For hundreds of images
#colmap exhaustive_matcher \
#--SiftMatching.use_gpu 0 \
#--database_path ${PROJECT}/database.db

#For 1000 - 10,000 images
#Download bin from https://demuc.de/colmap/
colmap vocab_tree_matcher \
--SiftMatching.use_gpu 0 \
--database_path ${PROJECT}/database.db \
--VocabTreeMatching.vocab_tree_path ${PWD}/vocab_tree_flickr100K_words256K.bin
#--SiftMatching.max_num_matches 4000

##For 10,000 - 100,000 images
##Download bin from https://demuc.de/colmap/
#colmap vocab_tree_matcher \
#--SiftMatching.use_gpu 0 \
#--database_path ${PROJECT}/database.db \
#--VocabTreeMatching.vocab_tree_path ${PWD}/vocab_tree_flickr100K_words1M.bin

##For less than 1000 images
#colmap mapper \
#--database_path ${PROJECT}/database.db \
#--image_path ${PROJECT}/images \
#--output_path ${PROJECT}/sparse 

##STILL TOO SLOW#For more than 1000 images
colmap mapper \
--database_path ${PROJECT}/database.db \
--image_path ${PROJECT}/images \
--output_path ${PROJECT}/sparse \
--Mapper.ba_global_images_ratio 1.2 \
--Mapper.ba_global_points_ratio 1.2 \
--Mapper.ba_global_max_num_iterations 20 \
--Mapper.ba_global_max_refinements 3 \
--Mapper.ba_global_points_freq 200000 \
--Mapper.ba_global_use_pba 1

###For more than 1000 images
#colmap hierarchical_mapper \
#--database_path ${PROJECT}/database.db \
#--image_path ${PROJECT}/images \
#--output_path ${PROJECT}/sparse 


#colmap point_triangulator \
#    --database_path ${PROJECT}/database.db \
#    --image_path ${PROJECT}/images \
#    --output_path ${PROJECT}/sparse

find ${PROJECT}/sparse/ -maxdepth 1 -mindepth 1 | while read areconstruction; do

	colmap image_undistorter \
		--image_path ${PROJECT}/images \
		--input_path ${areconstruction} \
		--output_path ${PROJECT}/dense$(basename ${areconstruction}) \
		--output_type COLMAP 

	colmap model_converter \
		--input_path ${PROJECT}/dense$(basename ${areconstruction})/sparse \
		--output_path ${PROJECT}/dense$(basename ${areconstruction})/sparse  \
		--output_type TXT

	${PWD}/openMVS_build/bin/InterfaceCOLMAP \
		--working-folder ${PROJECT}/ \
		-i ${PROJECT}/dense$(basename ${areconstruction}) \
		--output-file ${PROJECT}/model_colmap_$(basename ${areconstruction}).mvs

	${PWD}/openMVS_build/bin/DensifyPointCloud \
		--input-file ${PROJECT}/model_colmap_$(basename ${areconstruction}).mvs \
		--working-folder ${PROJECT}/ \
		--output-file ${PROJECT}/model_dense_$(basename ${areconstruction}).mvs \
		--archive-type -1

	${PWD}/openMVS_build/bin/ReconstructMesh --input-file ${PROJECT}/model_dense_$(basename ${areconstruction}).mvs \
		--working-folder ${PROJECT}/ \
		--output-file ${PROJECT}/model_dense_mesh_$(basename ${areconstruction}).mvs

#	${PWD}/openMVS_build/bin/RefineMesh \
#		--resolution-level 1 \
#		--input-file ${PROJECT}/model_dense_mesh_$(basename ${areconstruction}).mvs \
#		--working-folder ${PROJECT}/ \
#		--output-file ${PROJECT}/model_dense_mesh_refine_$(basename ${areconstruction}).mvs

	if ! [ -f "${PROJECT}/model_dense_mesh_refine_$(basename ${areconstruction}).mvs" ]; then
		${PWD}/openMVS_build/bin/TextureMesh \
			--export-type obj \
			--output-file ${PROJECT}/model_$(basename ${areconstruction}).obj \
			--working-folder ${PROJECT}/ \
			--input-file ${PROJECT}/model_dense_mesh_$(basename ${areconstruction}).mvs \
			--resolution-level 2 \
			--decimate 0.05
	else 
		${PWD}/openMVS_build/bin/TextureMesh \
			--export-type obj \
			--output-file ${PROJECT}/model_$(basename ${areconstruction}).obj \
			--working-folder ${PROJECT}/ \
			--input-file ${PROJECT}/model_dense_mesh_refine_$(basename ${areconstruction}).mvs \
			--resolution-level 2 \
			--decimate 0.05
	fi
done

umask "${OLD_UMASK}"
